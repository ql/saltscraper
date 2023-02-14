require 'bundler/setup'

Bundler.require
require 'active_record'

require __dir__ + '/config/configuration.rb'
Dir[__dir__ + '/app/**/*.rb'].each &method(:require)

class Application
  class << self
    attr_accessor :logger

    def app_env
      @app_env ||= ENV['APP_ENV'] || 'development'
    end

    def config
      Configuration
    end

    # Possible improvement: add path to logfile here
    def init_logger(level)
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
    Application.logger.info { "App loaded!" }
    Application.logger.debug { "Single request time window is set to #{self.class.config.worker_delay}" }
    create_connection
    add_urls
    check_store_dir
    run_workers
  end

  private

  def create_connection
    ActiveRecord::Base.establish_connection(
      adapter: Application.config.database_settings['adapter'],
      database: Application.config.database_settings['database']
    )
  end

  def add_urls
    return unless @start_options[:url_list]
    Application.logger.debug { "Adding urls from #{@start_options[:url_list]}" }
    AddUrls.new(@start_options[:url_list]).call
  end

  def check_store_dir
    return if File.exists?(UrlEntry::FILE_STORE)

    Dir.mkdir(UrlEntry::FILE_STORE)
  end

  def run_workers
    Application.logger.debug { "Starting workers" }
    threads = []
    self.class.config.settings['workers'].times do
      threads << Thread.new do
        Worker.new.start
      end
    end
    threads.each(&:join)
  end
end

