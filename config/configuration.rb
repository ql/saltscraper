class Configuration
  class << self
    def database_settings
      @database_settings ||=
        YAML.load_file('./config/database.yml').fetch(Application.app_env)
    end

    def settings
      @settings ||= YAML.load_file('./config/settings.yml')
    end

    def worker_delay
      @delay ||=
        settings['limit_window_minutes'] * 60.0 /
        settings['limit_window_attempts'].to_f *
        settings['workers']
    end

    # !!! entry point for working with scraped HTML !!!
    # possible optimization - move to separate thread/background
    def post_receive_callback(body, url)
      html_doc = Nokogiri::HTML(body)
      PageTitle.create!(url: url, title: html_doc.title)
    end
  end
end
