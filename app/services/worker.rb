# Gets urls from DB, and sends them to processor respecting rate throttle
class Worker
  BATCH_SIZE = 10

  def start
    Application.logger.info { "Starting worker..." }
    loop do
      process_batch
    end
  end

  def process_batch
    batch = nil
    UrlEntry.transaction do
      batch = UrlEntry.pending.order(id: :asc).limit(BATCH_SIZE).to_a
      UrlEntry.where(id: batch.map(&:id)).update_all(processing_started_at: Time.now)
    end
    Application.logger.debug { "Got batch #{batch.inspect}..." }
    Thread.exit if batch.empty? # here we can add sleep for daemon-like behavior

    batch.each do |url_entry|
      with_delay do
        RequestProcessor.new(url_entry).call
      end
    end
  end

  private

  def with_delay
    start_at = Time.now
    yield
    delay_left = Application.config.worker_delay - (Time.now - start_at)
    sleep(delay_left) if delay_left.positive?
  end
end
