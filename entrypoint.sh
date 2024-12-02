#!/bin/bash
set -e

/docker-entrypoint.sh rails server -b 0.0.0.0 &

echo "Waiting for Redmine to be ready..."
until curl -s http://localhost:3000 > /dev/null; do
  sleep 5
done
echo "Redmine is ready!"

bundle exec rails runner - <<-RUBY
  admin = User.find_by(login: 'admin')
  if admin
    admin.password = 'password'
    admin.password_confirmation = 'password'
    admin.save!

    if admin.api_key.nil?
      admin.api_key = User.generate_api_key
      admin.save!
    end

    puts "Admin API Key: #{admin.api_key}"
  else
    raise 'Admin not found'
  end

  project = Project.find_or_create_by(name: 'Test Project', identifier: 'test-project')

  Issue.find_or_create_by(
    project: project,
    subject: 'Test Issue',
    description: 'This is a test issue for CI/CD'
  )

  puts 'Setup completed successfully!'
RUBY

wait
