APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")).freeze 
$LOAD_PATH << File.join(APP_ROOT, 'lib') unless $LOAD_PATH.include?(File.join(APP_ROOT, 'lib'))

require 'capybara/poltergeist'
require 'classy_testudo_brains'
require 'mongo'
require 'mongo_mapper'

# => Configure the MongoDB Connection
File.open(File.join(APP_ROOT, 'config', 'mongo.yml'), 'r') do |f|
  cfg = (YAML::load(f.read)).symbolize_keys
  MongoMapper.connection = Mongo::Connection.new(cfg[:host] || 'localhost', cfg[:port] || 27017)
  MongoMapper.database = cfg[:database] || "umd_waitlist"
  if (cfg[:username] and cfg[:password])
    MongoMapper.database.authenticate(cfg[:username], cfg[:password])
  end
end

require "models"