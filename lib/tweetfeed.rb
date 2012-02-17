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

  # Search for hashtags at Twitter
  def search 
    tweets = Hash.new
    begin
      @hashtags.each do |tag|
        tweets["#{tag}"] = @twitter.search("##{tag} -rt", :since_id => @last_id, :include_entities => 1, :with_twitter_user_id => 1 )
        #tweets["#{tag}"] = @twitter.search("##{tag} -rt", :since_id => @last_id, :include_entities => 0, :with_twitter_user_id => 1 )
      end
      #tweets['hadoop'].each {|t| puts t['id']}
      tweets
    rescue EOFError, SocketError
      @logger.error "Connection to Twitter not available."
    end
  end

  # Make all results available in one array
  def combine(tweets)
    arr = Array.new
    @hashtags.each do |tag| 
      tweets["#{tag}"].each do |tweet|
        arr << tweet
      end 
    end
    arr
  end

  def filter_tweets(tweets)
    arr = Array.new
    @hashtags.each do |tag|
      tweets["#{tag}"].each do |tweet|
        #p tweet['attrs']['entities']['urls'][0]['url'] unless tweet['attrs']['entities']['urls'].empty?
        arr << tweet unless tweet['attrs']['entities']['urls'].empty?
      end
    end
    arr
  end

end

