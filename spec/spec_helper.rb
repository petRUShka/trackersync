# frozen_string_literal: true

require 'dotenv/load'
require 'rest-client'
require 'json'
require_relative './support/redmine_helpers'

RSpec.configure do |config|
  config.include RedmineHelpers
end
