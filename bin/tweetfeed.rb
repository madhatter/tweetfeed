#!/usr/bin/env ruby

require_relative '../lib/tweetfeed.rb'
require_relative '../lib/tweetfeed_config.rb'

begin
  @config = TweetfeedConfig.new
  
  @tweetfeed = Tweetfeed.new(@config)
  @tweetfeed.run
end

