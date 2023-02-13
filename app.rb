require 'bundler/setup'

Bundler.require
require 'active_record'

Dir[__dir__ + '/app/**/*.rb'].each &method(:require)
Dir[__dir__ + '/config/*.rb'].each &method(:require)



class Application
  class << self
    attr_accessor :logger

    def app_env
      @app_env ||= ENV['APP_ENV'] || 'development'
    end

    def config
      Configuration
    end

    def init_logger(level) # makes sense to add path to logfile here
      @logger =
        Logger.new(STDOUT).tap do |logger|
          logger.level = level || :error
        end
    end
  end

  def initialize(options)
    self.class.init_logger(options[:verbose] && :debug)

    @start_options = {
      url_list: options[:url_list]
    }
  end

  def start!
    ActiveRecord::Base.establish_connection(
      adapter: Application.config.database_settings['adapter'],
      database: Application.config.database_settings['database']
    )

    Application.logger.info { "App loaded!" }

    if @start_options[:url_list]
      AddUrls.new(@start_options[:url_list]).call
    end
  end
end

