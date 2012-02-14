#!/usr/bin/env ruby

require_relative '../lib/tweetfeedd.rb'
require_relative '../lib/tweetfeed_config.rb'
require_relative '../lib/tweetfeed.rb'

begin
  @config = TweetfeedConfig.new
  
  @tweetfeed = Tweetfeed.new(@config)
  @tweetfeed.search

  #daemon = Tweetfeedd.new
  #daemon.run 

end

