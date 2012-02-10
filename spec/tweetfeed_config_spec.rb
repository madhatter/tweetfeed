require_relative '../lib/tweetfeed_config.rb'
require 'yaml'

describe TweetfeedConfig do
  before :each do
    @tweetfeed_conf = TweetfeedConfig.new
    config_file = File.join(Dir.pwd, 'test_config.yml')
  end
end
