#!/usr/bin/env ruby

require_relative '../lib/tweetfeedd.rb'
require_relative '../lib/tweetfeed_config.rb'
require_relative '../lib/tweetfeed.rb'

begin
  @config = TweetfeedConfig.new
  
  @tweetfeed = Tweetfeed.new(@config)
  tweets = @tweetfeed.search
  #tweets_combi = @tweetfeed.combine(tweets)
  #tweets_combi.each {|tweet| puts tweet['id']}
  #tweets_combi.each {|tweet| p tweet}
  url_tweets = @tweetfeed.filter_tweets(tweets)
  #p url_tweets
  @tweetfeed.generate_rss_feed(url_tweets)
  #
  #daemon = Tweetfeedd.new
  #daemon.run 

end

