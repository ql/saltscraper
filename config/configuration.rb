class Configuration
  class << self
    def database_settings
      @database_settings ||=
        YAML.load_file('./config/database.yml').fetch(Application.app_env)
    end

    def settings
      @settings ||= YAML.load_file('./config/settings.yml')
    end

    def post_receive_callback(body, url)
      puts "Received body!" # TODO - add saving page title
    end

    def worker_delay
      @delay ||= 
        settings['limit_window_minutes'] * 60.0 /
        settings['limit_window_attempts'].to_f *
        settings['workers']
    end
  end
end
