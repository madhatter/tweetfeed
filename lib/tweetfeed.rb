require 'twitter'
require 'curb'
require 'json'
require 'logger'

require_relative '../lib/tweetfeed_config.rb'

class Tweetfeed
  def initialize(config)
    @log_level = config.log_level
    @hashtags = config.hashtags
    @last_id = config.last_id

    @logger = Logger.new(STDOUT)
    @logger.level = @log_level
    @twitter = Twitter::Client.new
  end
end

