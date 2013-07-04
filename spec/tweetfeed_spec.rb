require 'spec_helper.rb'
require 'yaml'
require_relative '../lib/tweetfeed_config.rb'
require_relative '../lib/tweetfeed.rb'

describe Tweetfeed do
  before :each do
    logger = double(:logger, :info => nil, :level= => nil, :error => nil)
    @tweetfeed_conf = TweetfeedConfig.new logger
    config_file = File.join(Dir.pwd, 'spec', 'test_config.yml')
    @tweetfeed_conf.read config_file
    @tweetfeed = Tweetfeed.new(@tweetfeed_conf)

    tweets_file = File.join(Dir.pwd, 'spec', 'tweets.yml')
    @tweets_array = YAML.load_file(tweets_file)
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

  it "should calculate the correct latest id from search results" do
    tf = @tweetfeed
    response = tf.calculate_last_id @tweets_array
    response.should == 352505432557879296
  end
end

