module Octobox
  class OpenCollective
    PERIOD = 1.month.ago
    INDIVIDUAL_COST_PER_PERIOD = 10
    ORGANISATION_COST_PER_PERIOD= 100

    def self.sync
      Rails.logger.info("n\n\033[32m[#{Time.current}] INFO -- Syncing Open Collective supporters \033[0m\n\n")

      response = Oj.load(Typhoeus.get("https://opencollective.com/octobox/members.json").body)

      organisation_subscribers = get_sub_names(response, ORGANISATION_COST_PER_PERIOD)
      individual_subscibers = get_sub_names(response, INDIVIDUAL_COST_PER_PERIOD)
      individual_subscibers.delete_if { |name| organisation_subscribers.include?(name) }

      apply_plan(organisation_subscribers, 'Open Collective Organisation')
      apply_plan(individual_subscibers, 'Open Collective Individual')
    end

    def self.get_sub_names(transactions, cost)
      txs = transactions.select do |item|
        Date.parse(item["lastTransactionAt"]) > PERIOD && item["github"].present?
      end
      # check for users who have made multiple donations in the last month that tipped the jar
      tx_groups = txs.group_by{|item| item["github"].presence}

      subscriptions = tx_groups.select do |_name, group|
        group.sum{|item| item['lastTransactionAmount']} >= cost
      end

      subscriber_names = subscriptions.map do |name, _transactions|
        rz = name.match(/github.com\/(\w+)/i) if name
        rz[1] if rz
      end.compact

      return subscriber_names
    end

    def self.apply_plan(subscriber_names, plan_name)
      plan = SubscriptionPlan.find_by_name(plan_name)
      return Rails.logger.info("n\n\033[32m[#{Time.current}] ERROR -- Could not find plan named #{plan_name}\033[0m\n\n") if plan.nil?

      current_subs_purchases = plan.subscription_purchases.where(unit_count: 1) unless plan.nil?

      if current_subs_purchases
        current_subs_purchases.each do |purchase|
          unless subscriber_names.include? purchase.app_installation.account_login
            purchase.update_attributes(unit_count: 0)
            Rails.logger.info("n\n\033[32m[#{Time.current}] INFO -- Removed open collective subscription purchase for #{purchase.app_installation.account_login}\033[0m\n\n")
          end
        end
      end

      subscriber_names.each do |subscriber|
        app_installation = AppInstallation.find_by_account_login(subscriber)

        next if app_installation.nil?

        subscription_purchase = app_installation.subscription_purchase

        if subscription_purchase.nil?
          app_installation.subscription_purchase.create(plan: plan, unit_count: 1)
          Rails.logger.info("n\n\033[32m[#{Time.current}] INFO -- Added open collective subscription purchase for #{subscriber}\033[0m\n\n")
        elsif subscription_purchase.unit_count.zero?
          subscription_purchase.update_attributes(plan: plan, unit_count: 1)
          Rails.logger.info("n\n\033[32m[#{Time.current}] INFO -- Restarted open collective subscription purchase for #{subscriber}\033[0m\n\n")
        else
          Rails.logger.info("n\n\033[32m[#{Time.current}] INFO -- Renewed open collective subscription purchase for #{subscriber}\033[0m\n\n")
        end
      end
    end
  end
end
