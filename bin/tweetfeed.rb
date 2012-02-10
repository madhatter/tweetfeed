#!/usr/bin/env ruby

require_relative '../lib/tweetfeedd.rb'

begin
  daemon = Tweetfeedd.new()
  daemon.run 

end

