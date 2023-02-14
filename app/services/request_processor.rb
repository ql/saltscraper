# Processes individual UrlEntry, handles response
class RequestProcessor
  attr_reader :url_entry

  def initialize(url_entry)
    @url_entry = url_entry

    if url_entry.processed_at || url_entry.failed_at
      raise "Invalid state for #{url_entry.inspect}"
    end
  end

  def call
    Application.logger.debug { "processing request #{url_entry.id}" }

    response = connection.get(url_entry.url)
    if response.success?
      url_entry.save_response_body(response.body)
      fire_callback(response.body,url_entry.url)
    end
    url_entry.update(processed_at: Time.now, http_status: response.status)
  rescue Faraday::Error => e
    Application.logger.error { "Got error #{e.inspect}" }
    url_entry.update(failed_at: Time.now, error: e.message)
  end

  private

  # Ideally we should use net_http_persistent and re-use this connection
  def connection
    @connection ||=
      Faraday.new(url: url_entry.url) do |faraday|
        faraday.adapter :net_http
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

  def fire_callback(body, url)
    Application.config.post_receive_callback(body, url)
  end
end
