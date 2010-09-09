desc "Load default applications and pin_types to development"
task :load_apps => :environment do
  require 'active_record/fixtures'
  ActiveRecord::Base.establish_connection(RAILS_ENV || :development)
  apps = File.join(RAILS_ROOT, 'test', 'fixtures', 'apps.yml')
  Fixtures.create_fixtures('test/fixtures', File.basename(apps,'.*'))
  apps = File.join(RAILS_ROOT, 'test', 'fixtures', 'pin_types.yml')
  Fixtures.create_fixtures('test/fixtures', File.basename(apps,'.*'))
end