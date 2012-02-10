require_relative '../lib/tweetfeedconfig.rb'
require 'yaml'

describe TweetfeedConfig do
  before :each do
    @tweetfeed_conf = TweetfeedConfig.new
    config_file = File.join(Dir.pwd, 'test_config.yml')
  end
end
