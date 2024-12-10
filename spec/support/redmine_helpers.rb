# frozen_string_literal: true

module RedmineHelpers
  def redmine_url
    ENV.fetch('REDMINE_URL', 'http://localhost:3000')
  end

  def api_key
    ENV.fetch('REDMINE_API_KEY', 'admin_api_key')
  end

  def headers
    { 'Content-Type' => 'application/json', 'X-Redmine-API-Key' => api_key }
  end

  def issue_titles
    ['Test Task 1', 'Test Task 2']
  end

  def fetch_issues
    response = RestClient.get("#{redmine_url}/issues.json", headers)
    JSON.parse(response.body)['issues']
  end

  def find_issue_by_subject(subject, issues)
    issues.find { |issue| issue['subject'] == subject }
  end

  def create_test_issues
    issue_titles.each do |title|
      RestClient.post(
        "#{redmine_url}/issues.json",
        { issue: { subject: title, project_id: 'test-project' } }.to_json,
        headers
      )
    end
  end
end
