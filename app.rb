require 'bundler/setup'

Bundler.require
require 'active_record'

Dir[__dir__ + '/app/**/*.rb'].each &method(:require)
Dir[__dir__ + '/config/*.rb'].each &method(:require)



class Application
  class << self
    def app_env
      @app_env ||= ENV['APP_ENV'] || 'development'
    end

    def config
      Configuration
    end
  end
end

ActiveRecord::Base.establish_connection(
  adapter: Application.config.database_settings['adapter'],
  database: Application.config.database_settings['database']
)

puts "App loaded!"
