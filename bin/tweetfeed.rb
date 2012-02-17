#!/usr/bin/env ruby

require_relative '../lib/tweetfeedd.rb'

begin
  #@config = TweetfeedConfig.new
  
  #@tweetfeed = Tweetfeed.new(@config)
  #@tweetfeed.run

  
  daemon = Tweetfeedd.new
  daemon.run 

end

