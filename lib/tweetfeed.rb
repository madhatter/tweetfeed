require 'twitter'
require 'curb'
require 'json'
require 'logger'
require 'rss/maker'

require_relative '../lib/tweetfeed_config.rb'

class Tweetfeed
  def initialize(config)
    @log_level = config.log_level
    @hashtags = config.hashtags
    @last_id = config.last_id
    @rss_outfile = config.rss_outfile

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

  def generate_rss_feed(tweets)
    version = "2.0"

    @logger.info "Generating RSS feed to #{@rss_outfile}."

    content = RSS::Maker.make(version) do |m|
      m.channel.title = "tweetfeed RSS feed #{@hashtags}"
      m.channel.link = "http://github.com/madhatter/tweetfeed"
      m.channel.description = "Automatically generated news from Twitter hashtags"
      m.items.do_sort = true # sort items by date

      tweets.each do |tweet|
        url = tweet['attrs']['entities']['urls'][0]['url']
        title = tweet['text'].sub(/(#{url})/, "") 
        @logger.info "URL: #{url}"
        @logger.info "New Title: #{title}"

        i = m.items.new_item
        i.title = title
        i.link = tweet['attrs']['entities']['urls'][0]['url'] 
        i.date = tweet['created_at']
      end
    end

    File.open(@rss_outfile, "w") do |file|
      file.write(content)
    end
  end
end

