# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Redmine API' do
  let(:issues) { fetch_issues }

  before(:all) do
    create_test_issues
  end

  describe 'Issues existence' do
    it 'verifies all issues exist in Redmine' do
      titles = issues.map { |issue| issue['subject'] }

      issue_titles.each do |title|
        expect(titles).to include(title)
      end
    end
  end

  describe 'Issues project assignment' do
    it 'verifies all issues are assigned to the project' do
      issue_titles.each do |title|
        issue = find_issue_by_subject(title, issues)
        expect(issue['project']['name']).to eq('Test Project')
      end
    end
  end

  describe 'Issues accessibility' do
    it 'verifies all tasks are accessible via their IDs' do
      issues.each do |issue|
        task_id = issue['id']
        response = RestClient.get("#{redmine_url}/issues/#{task_id}.json", headers)
        expect(response.code).to eq(200)
      end
    end
  end
end
