require_relative '../lib/tweetfeed_config.rb'
require 'yaml'

describe TweetfeedConfig do
  before :all do
    @tweetfeed_conf = TweetfeedConfig.new
    config_file = File.join(Dir.pwd, 'spec', 'test_config.yml')
    @tweetfeed_conf.read config_file
  end

  it "should have some configurations set" do
    config = @tweetfeed_conf
    response = config.log_level
    response.should == 0
  end

  it "should have three hashtags found" do
    config = @tweetfeed_conf
    response = config.hashtags.size
    response.should == 3
  end

  it "should save an updated last_id" do
    config = @tweetfeed_conf
    config.last_id = 12
    config.write

    config.read
    response = config.last_id
    response.should == 12
  end
end
