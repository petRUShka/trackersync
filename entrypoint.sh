#!/bin/bash
set -e

/docker-entrypoint.sh rake db:migrate
/docker-entrypoint.sh rake redmine:load_default_data RAILS_ENV=production REDMINE_LANG=en

/docker-entrypoint.sh rails server -b 0.0.0.0 &

echo "Waiting for Redmine to be ready..."
until curl -s http://localhost:3000 > /dev/null; do
  sleep 5
done
echo "Redmine is ready!"

bundle exec rails runner - <<-RUBY
  begin
    Setting['rest_api_enabled'] = '1'

    admin = User.find_by(login: 'admin')
    admin.password = 'password'
    admin.password_confirmation = 'password'
    admin.status = User::STATUS_ACTIVE
    if admin.save
      puts 'Admin updated successfully.'
    else
      puts 'Failed to update admin:'
      puts admin.errors.full_messages
    end

    if admin.api_key.nil?
      admin.generate_api_key
      admin.save!
    end

    puts "Admin API Key: #{admin.api_key}"

    project = Project.find_or_create_by(identifier: 'test-project') do |p|
      p.name = 'Test Project'
    end

    if project.persisted?
      puts 'Project created successfully.'
    else
      puts 'Failed to create project'
      puts project.errors.full_messages
    end

    user = User.new(
      login: 'testuser',
      firstname: 'Test',
      lastname: 'User',
      mail: 'user@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
    user.admin = false
    user.status = User::STATUS_ACTIVE

    if user.save
      puts 'Test user created successfully.'
    else
      puts 'Failed to create test user'
      puts user.errors.full_messages
    end

    if user.api_key.nil?
      user.generate_api_key
      user.save!
    end

    puts "Test User API Key: #{user.api_key}"

    role = Role.find_by(name: 'Manager')

    if role
      member = Member.new(user: user, project: project)
      member.role_ids = [role.id]
      if member.save
        puts 'User added to project successfully'
      else
        puts 'Failed to add user to project'
        puts member.errors.full_messages
      end
    else
      puts 'No suitable role found. User not added to project.'
    end

    puts 'Setup completed successfully!'
  rescue => e
    puts "An error occurred: #{e.message}"
    puts e.backtrace
    exit 1
  end
RUBY

wait
