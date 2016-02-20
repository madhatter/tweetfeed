require 'net/http'
require 'logger'

class UrlParser
  def initialize config
    @config = config
    @logger = Logger.new(STDOUT)
    @logger.level = @config.log_level
  end

  def get_original_url url
    redirect_url = url
    @logger.debug "Fetching original url for #{url}"

    while url == redirect_url do
      res = Net::HTTP.get_response(URI(url.gsub('https', 'http')))
      redirect_url = res['location']
    end
    redirect_url
  end
end
