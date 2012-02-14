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

  def search 
    @hashtags.each do | tag |
      @twitter.search("##{tag} -rt", :since_id => 168708216706973696, :include_entities => 1, :with_twitter_user_id => 1 ).each do |result|
        puts result.text
      end
    end
  end
end

