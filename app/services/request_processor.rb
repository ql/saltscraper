class RequestProcessor
  attr_reader :url_entry

  def initialize(url_entry)
    @url_entry = url_entry
  end

  def call
    Application.logger.debug { "processing request #{url_entry.id}" }
    response = Downloader.new(url_entry.url).call
    url_entry.update(
      processed_at: Time.now,
      http_status: response.status
    )
    if response.success?
      url_entry.save_response_body(response.body)
      fire_callback(response.body,url_entry.url)
    end
    response
  rescue Faraday::Error => e # retries are handled in Downloader
    Application.logger.debug { "Got error #{e.inspect}" }
    url_entry.update(
      failed_at: Time.now,
      error: e.message
    )
  end

  private

  def fire_callback(body, url)
    Application.config.post_receive_callback(body, url)
  end
end
