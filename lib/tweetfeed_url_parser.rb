require 'net/http'
require 'logger'

class UrlParser
  def initialize config
    @config = config
    @logger = Logger.new(STDOUT)
    @logger.level = @config.log_level
  end

  def get_original_url url
    redirect_url = nil
    @logger.debug "Fetching original url for #{url}"

    while url != redirect_url do
      @logger.debug "Looking..."
      uri = URI.parse(url)
      if uri.scheme == 'https'
        uri.port = Net::HTTP.https_default_port()

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this

        response = http.get2(uri)
      else
        response = Net::HTTP.get_response(uri)
      end

      redirect_url = response['location']
      if redirect_url.nil?
        redirect_url = url
      end

      @logger.debug "Found #{redirect_url}"
      @logger.debug "For   #{url}"
      url = redirect_url
    end
      redirect_url
  end
end
