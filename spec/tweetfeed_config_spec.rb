require 'spec_helper.rb'
require 'yaml'
require_relative '../lib/tweetfeed_config.rb'

describe TweetfeedConfig do
  before :each do
    logger = double(:logger, :level => "3", :info => nil, :level= => nil, :error => "error")
    @tweetfeed_conf = TweetfeedConfig.new logger
    config_file = File.join(Dir.pwd, 'spec/data', 'test_config.yml')
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

  it "should raise an error when there are no hashtags" do
    config = @tweetfeed_conf
    config_file = File.join(Dir.pwd, 'spec/data', 'test_config_no_hashtags.yml')
    lambda {config.read config_file}.should raise_error
  end

  it "should receive an error message when there are no hashtags, too" do
    config = @tweetfeed_conf
    config_file = File.join(Dir.pwd, 'spec/data', 'test_config_no_hashtags.yml')
    config.logger.should_receive(:error).with("No Hashtags found. Exiting.")
    lambda {config.read config_file}.should raise_error
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

