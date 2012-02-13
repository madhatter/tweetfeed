require_relative '../lib/tweetfeed_config.rb'
require 'yaml'

describe TweetfeedConfig do
  before :each do
    @tweetfeed_conf = TweetfeedConfig.new
    config_file = File.join(Dir.pwd, 'spec', 'test_config.yml')
    @tweetfeed_conf.read config_file
  end

  it "should have some configurations set" do
    config = @tweetfeed_conf
    response = config.log_level
    response.should == 3
  end

  it "should have three hashtags found" do
    config = @tweetfeed_conf
    response = config.hashtags.size
    response.should == 3
  end
end
