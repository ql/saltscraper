# Takes urls from file, saves to DB
class AddUrls
  def initialize(path)
    @path = path
  end

  def call
    counter = 0
    File.open(@path).each_line do |line|
      url = line.strip
      if valid_url?(url)
        enqueue_url(url) # FIXME - it's SLOW, should use batch insert
        counter += 1
      else
        Application.logger.error { "Cannot parse URL `#{url}`, skipping" }
        next
      end
    end
    Application.logger.info { "Enqueued #{counter} urls" }
  end

  private

  def enqueue_url(url)
    UrlEntry.create!(url: url)
  end

  def valid_url?(url)
    URI.parse(url).hostname.present? rescue false
  end
end
