# This will migrate database for tests which touch the dd, and avoids migration for unit tests
# File needs to be required in tests that work with the DB

RSpec.configure do |c|
  # this defines a suite level hook - it runs once, before all the specs have been loaded, but before the first one actually runs
  c.before(:suite) do
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrations')
    DB[:expenses].truncate
  end

  c.around(:example, :db) do |example|
    DB.transaction(rollback: :always) { example.run }
  end
end
