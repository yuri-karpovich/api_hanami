require 'bundler/setup'
require 'require_all'
require 'hanami/api'
require 'hanami/middleware/body_parser'
require 'fast_jsonapi'
require 'active_record'
require 'yaml'
require 'log4r'

require_all 'app/models'
require_all 'app/serializers'

# Logger
LOG       = Log4r::Logger.new('log')
LOG.level = Log4r::ERROR
LOG.outputters << Log4r::StdoutOutputter.new('log_stdout')

# ActiveRecord connection
DB_CONFIG_PATH = 'db/config.yml'.freeze
ActiveRecord::Base.logger = LOG
ActiveRecord::Base.establish_connection(YAML::load(File.open(DB_CONFIG_PATH))[ENV['RACK_ENV']])
