require 'twitter'
require 'curb'

require_relative '../lib/tweetfeed_config.rb'
require_relative '../lib/tweetfeed_rss_generator.rb'

class Tweetfeed
  def initialize(config)
    @config = config
    @log_level = config.log_level
    @hashtags = config.hashtags
    @last_id = config.last_id

    @logger = Logger.new(STDOUT)
    @logger.level = @log_level
    @generator = TweetfeedGenerator.new @config
    #@twitter = Twitter::Client.new
    @twitter =  Twitter.configure do |config|
		  config.consumer_key = "JOaCrxrtn8eKgCVOlpWRQ"
		  config.consumer_secret = "brBx60OPfT6DlveRdxuwUFhdTBP9P9xIDbgol3UP8pU"
		  config.oauth_token = "218466084-18G5H2rAWZaMqJH618Dtu7sPGrfHYfAWZIHyyVGd"
		  config.oauth_token_secret = "t6s6H081tGhQew0tBfWZXd6nYsr43NkxMZ8Tgdhd8"
		end
  end

  # Starts the search and generates the RSS feed file.
  def run
    @logger.debug "LastId is " + @last_id.to_s
    tweets = collect_tweets
    
    @generator.generate_rss_file tweets unless tweets.instance_of? NilClass
    
    # the last thing we do:
    @config.write
    @logger.info "....and we are done.\n\n"
  end

  # Search for hashtags at Twitter
  def collect_tweets
    result = []
    begin
      @hashtags.each do |hashtag|
        result.push search(hashtag)
      end

      # for debugging TODO remove later
      #result.pop.each do |status|
      #  puts status.id
      #end
      #exit

      store_last_id calculate_last_id result
      filter_tweets_with_urls result

    rescue EOFError, SocketError, Twitter::Error::ClientError
      @logger.error "Connection to Twitter seems to be not available."
      exit
    end
  end

  def search hashtag
    result = @twitter.search("##{hashtag} -rt", :since_id => @last_id, :include_entities => 1).statuses
  end

  # Get the max tweet id from the last search result
  def calculate_last_id tweets_array
    last_id = @last_id
    tweets_array.each do |tweets| 
      tweets.each do |t| 
        last_id = t['id'] if t['id'] > last_id 
      end
    end
    last_id
  end

  # Store the tweet id from the latest search in the configuration
  def store_last_id last_id
    @logger.info "Storing the last id to the configuration."
    @config.last_id = last_id
    @last_id = @config.last_id
  end

  # Filter the tweets for tweets with URLs only.
  def filter_tweets_with_urls tweets_array
    tweets_with_urls = []
    tweets_array.each do |tweets|
      tweets.each do |tweet|
        # TODO remove this, just for debugging
#       tweet.urls.each do |url| 
#         p url.display_url
#       end
       tweets_with_urls << tweet unless tweet.urls.empty?
      end
    end
    p tweets_with_urls
    tweets_with_urls
  end
end

