require 'test_helper'

class HomePageTest < ActionDispatch::IntegrationTest
  test 'main page without login is introduction page' do
    get root_path
    assert_select 'h1', text: 'Octobox'
    assert_select 'h3', text: 'Untangle your GitHub Notifications'
    assert_select 'h3', text: 'Sound like you?'
    assert_match 'figment of your imagination', response.body
    assert_select 'h5', text: "Don't lose track"
    assert_match 'Octobox adds an extra "archived" state', response.body
    assert_select 'h5', text: 'Keep your focus'
    assert_match 'Search and filter notifications', response.body
    assert_select 'h5', text: 'Stay fresh'
    assert_match 'Keep those notifications up to date', response.body
    assert_select 'h3', text: 'Run your own Octobox'
    assert_match 'There are a number of install options', response.body
    assert_select 'h3', text: 'Contribute'
    assert_match 'You can also help triage issues.', response.body
  end
end
