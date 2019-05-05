require 'sequel'
# this config creates a db/test or db/production based on the RACK_ENV
# won't override production db during testing
DB = Sequel.sqlite "./db/#{ENV.fetch('RACK_ENV', 'development')}.db"
