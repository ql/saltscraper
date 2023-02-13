class Downloader
  attr_reader :connection, :url

  # TODO: implement connection reuse
  def initialize(url, connection: nil)
    @url = url
    @connection = connection || open_connection
  end

  def call
    # we don't care about exceptions here, will handle them in the caller
    connection.get(url).body 
  end

  def open_connection
    Faraday.new(url: url) do |faraday|
      faraday.response :logger # log requests to STDOUT
      #faraday.adapter :net_http_persistent
    end
  end
end
