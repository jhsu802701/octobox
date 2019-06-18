class Subject < ApplicationRecord
  has_many :notifications, foreign_key: :subject_url, primary_key: :url
  has_many :labels, dependent: :delete_all
  has_many :users, through: :notifications
  has_many :comments, dependent: :delete_all
  belongs_to :repository, foreign_key: :repository_full_name, primary_key: :full_name, optional: true
  has_one :app_installation, through: :repository

  BOT_AUTHOR_REGEX = /\A(.*)\[bot\]\z/.freeze
  private_constant :BOT_AUTHOR_REGEX

  scope :label, ->(label_name) { joins(:labels).where(Label.arel_table[:name].matches(label_name)) }

  validates :url, presence: true, uniqueness: true

  after_save :push_to_channels

  def update_labels(remote_labels)
    existing_labels = labels.to_a
    remote_labels.each do |l|
      label = labels.find_by_github_id(l['id'])
      if label.nil?
        labels.create({
          github_id: l['id'],
          color: l['color'],
          name: l['name'],
        })
      else
        label.github_id = l['id'] # smoothly migrate legacy labels
        label.color = l['color']
        label.name = l['name']
        label.save if label.changed?
      end
    end

    remote_label_ids = remote_labels.map{|l| l['id'] }
    deleted_labels = existing_labels.reject{|l| remote_label_ids.include?(l.github_id) }
    deleted_labels.each(&:destroy)
    push_to_channels if existing_labels != labels.to_a
  end

  def sync_involved_users
    return unless Octobox.github_app?
    involved_user_ids.each { |user_id| SyncNotificationsWorker.perform_in(1.minutes, user_id) }
  end

  def self.sync(remote_subject)
    subject = Subject.find_or_create_by(url: remote_subject['url'])

    # webhook payloads don't always have 'repository' info
    if remote_subject['repository']
      full_name = remote_subject['repository']['full_name']
    elsif remote_subject['full_name']
      full_name = remote_subject['full_name']
    else
      full_name = extract_full_name(remote_subject['url'])
    end

    comment_count = remote_subject['comments'] || remote_subject.fetch('commit', {})['comment_count']
    comment_count = subject.comment_count if comment_count.nil?

    subject.update({
      repository_full_name: full_name,
      github_id: remote_subject['id'],
      state: remote_subject['merged_at'].present? ? 'merged' : remote_subject['state'],
      author: remote_subject.fetch('user', {})['login'],
      html_url: remote_subject['html_url'],
      created_at: remote_subject['created_at'] || Time.current,
      updated_at: remote_subject['updated_at'] || Time.current,
      comment_count: comment_count,
      assignees: ":#{Array(remote_subject['assignees'].try(:map) {|a| a['login'] }).join(':')}:",
      locked: remote_subject['locked'],
      sha: remote_subject.fetch('head', {})['sha'],
      body: remote_subject['body'].try(:gsub, "\u0000", ''),
      draft: remote_subject['draft']
    })

    return unless subject.persisted?

    subject.update_labels(remote_subject['labels']) if remote_subject['labels'].present?
    subject.update_comments if Octobox.include_comments? && subject.has_comments?
    subject.update_status
    subject.sync_involved_users if (subject.saved_changes.keys & subject.notifiable_fields).any?
  end

  def self.sync_status(sha, repository_full_name)
    where(repository_full_name: repository_full_name).find_by_sha(sha)&.update_status
  end

  def has_comments?
     comment_count && comment_count > 0
  end

  def commentable?
    !comment_count.nil?
  end

  def update_status
    if sha.present?
      remote_status = download_status
      if remote_status.present?
        self.status = assign_status(remote_status)
        self.save if changed?
      end
    end
  end

  def author_url_path
    if bot_author?
      "/apps/#{BOT_AUTHOR_REGEX.match(author)[1]}"
    else
      "/#{author}"
    end
  end

  def update_comments
    remote_comments = download_comments
    return unless remote_comments.present?
    remote_comments.each do |remote_comment|
      comments.find_or_create_by(github_id: remote_comment.id) do |comment|
        comment.author = remote_comment.user.login
        comment.body = remote_comment.body.try(:gsub, "\u0000", '')
        comment.author_association = remote_comment.author_association
        comment.created_at = remote_comment.created_at
        comment.save
      end
    end
  end

  def comment(user, comment_body)
    return if comment_body.nil? || comment_body.empty?
    comment = comments.create(author: user.github_login, body: comment_body)
    CommentWorker.perform_async_if_configured(comment.id, user.id, self.id)
  end

  def comment_on_github(comment, user)
    return if comment.body.empty?

    client = user.comment_client(comment)

    remote_comment = client.post url.gsub('/pulls/', '/issues/') + '/comments', {body: comment.body}
    comment.github_id = remote_comment.id
    comment.author_association = remote_comment.author_association
    comment.created_at = remote_comment.created_at
    comment.save
  end

  def notifiable_fields
    ['state', 'assignees', 'locked', 'sha', 'comment_count', 'draft']
  end

  def push_to_channels
    notifications.includes({:subject => :labels}, :repository, {:user => :individual_subscription_purchase}).find_each(&:push_to_channel) if (saved_changes.keys & pushable_fields).any?
  end

  private

  def pushable_fields
    ['state', 'status', 'body', 'comment_count', 'draft']
  end

  def assign_status(remote_status)
    if remote_status.state == 'pending'
      remote_status.statuses.present? ? remote_status.state : nil
    else
      remote_status.state
    end
  end

  def download_status
    return unless github_client
    github_client.combined_status(repository_full_name, sha)
  rescue Octokit::ClientError
    nil
  end

  def download_comments
    return unless github_client
    github_client.get(url.gsub('/pulls/', '/issues/') + '/comments', since: comments.order('created_at ASC').last.try(:created_at))
  rescue Octokit::ClientError => e
    nil
  end

  def github_client
    if app_installation.present?
      app_installation.github_client
    else
      users.with_access_token.first&.github_client
    end
  end

  def self.extract_full_name(url)
    url.match(/\/repos\/([\w.-]+\/[\w.-]+)\//)[1]
  end

  def involved_user_ids
    involved_users = users.with_access_token.not_recently_synced
    involved_users += repository.users.with_access_token.not_recently_synced if repository.present?
    involved_users.uniq.reject(&:syncing?).map(&:id)
  end

  def bot_author?
    BOT_AUTHOR_REGEX.match?(author)
  end
end
