# Fires request to URL, knows nothing about UrlEntry
class Downloader
  attr_reader :connection, :url

  # TODO: implement connection reuse
  def initialize(url, connection: nil)
    @url = url
    @connection = connection || open_connection
  end

  def call
    Application.logger.debug { "fetching #{url}..." }
    # we don't care about exceptions here, will handle them in the caller
    connection.get(url)
  end

  def open_connection
    Faraday.new(url: url) do |faraday|
      #faraday.adapter :net_http_persistent # TODO see above
      faraday.request :retry, retry_options
    end
  end

  def retry_options
    {
      max: Application.config.settings['max_retries'],
      interval: 0.05,
      interval_randomness: 0.5,
      backoff_factor: 2
    }
  end
end
