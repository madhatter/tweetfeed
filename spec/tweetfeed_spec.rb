require 'spec_helper.rb'
require 'yaml'
require_relative '../lib/tweetfeed_config.rb'
require_relative '../lib/tweetfeed.rb'

describe Tweetfeed do
  before :each do
    logger = double(:logger, :level => "3", :info => nil, :level= => nil, :error => nil)
    @tweetfeed_conf = TweetfeedConfig.new logger
    config_file = File.join(Dir.pwd, 'spec/data', 'test_config.yml')
    @tweetfeed_conf.read config_file

    tweets_file = File.join(Dir.pwd, 'spec/data', 'tweets.yml')
    @tweets_array = YAML.load_file(tweets_file)

    tweets_base_result_file = File.join(Dir.pwd, 'spec/data', 'tweets_single_result_base.yml')
    @tweets_base_result = YAML.load_file(tweets_base_result_file)
    tweets_result_file = File.join(Dir.pwd, 'spec/data', 'tweets_single_result.yml')
    @tweets_result = YAML.load_file(tweets_result_file)

    twitter = double(:twitter, :search => @tweets_base_result, :statuses => @tweets_result)
    @tweetfeed = Tweetfeed.new(@tweetfeed_conf, twitter)
  end

  it "should raise an error when there are no hashtags here, too" do
    config = @tweetfeed_conf
    config_file = File.join(Dir.pwd, 'spec', 'test_config_no_hashtags.yml')
    lambda {config.read config_file}.should raise_error
  end

  it "should have some configurations set" do
    config = @tweetfeed_conf
    response = config.log_level
    response.should == 3
  end

  it "should find 3 tweets with urls" do
    tf = @tweetfeed
    response = tf.filter_tweets_with_urls @tweets_array
    response.size.should == 3
  end

  it "should start with the tweet id from the config" do
    config = @tweetfeed_conf
    config.last_id.should == 12
  end

  it "should return an array with tweets containing urls" do
    tf = @tweetfeed
    response = tf.filter_tweets_with_urls @tweets_array
    response.should be_an_instance_of Array
  end

  it "should calculate the correct latest id from search results" do
    tf = @tweetfeed
    response = tf.calculate_last_id @tweets_array
    response.should == 352505432557879296
  end

  it "should store the last_id in instance" do
    tf = @tweetfeed
    tf.store_last_id tf.calculate_last_id @tweets_array
    tf.last_id.should == 352505432557879296 
  end

  it "should search twitter" do
    tf = @tweetfeed
    result = tf.search "#rspec"
    result.should_not == nil
  end

  it "should collect an array of results" do
    tf = @tweetfeed
    result = tf.collect_tweets
    result.should be_an_instance_of Array
  end
end

