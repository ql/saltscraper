# Processes individual UrlEntry, handles response
class RequestProcessor
  attr_reader :url_entry

  def initialize(url_entry)
    @url_entry = url_entry
    raise "Invalid state for #{url_entry.inspect}" if url_entry.processed_at || url_entry.failed_at
  end

  def call
    Application.logger.debug { "processing request #{url_entry.id}" }

    return if url_cached

    response = connection.get(url_entry.url)
    url_entry.processed_at = Time.now
    url_entry.http_status = response.status
    if response.success?
      url_entry.save_response_body(response.body) # saved here
      fire_callback(response.body,url_entry.url)
    else
      url_entry.save!
    end
  rescue Faraday::Error => e
    Application.logger.error { "Got error #{e.inspect}" }
    url_entry.update(failed_at: Time.now, error: e.message)
  end

  private

  def url_cached
    # There might be cache expiration date check here
    existing_entry = UrlEntry.processed.find_by(url: url_entry.url)
    if existing_entry
      Application.logger.debug { "Cached version found for #{url_entry.url}, not downloading it" }
      url_entry.destroy
      fire_callback(existing_entry.html_content, existing_entry.url)
    else
      false
    end
  end

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
