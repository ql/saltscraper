class Configuration
  class << self
    def database_settings
      @database_settings ||=
        YAML.load_file('./config/database.yml').fetch(Application.app_env)
    end

    def settings
      @database_settings ||= YAML.load_file('./config/settings.yml')
    end
  end
end
