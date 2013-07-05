require 'spec_helper.rb'
require 'yaml'
require 'rss/2.0'
require_relative '../lib/tweetfeed_config.rb'
require_relative '../lib/tweetfeed_rss_generator.rb'

describe TweetfeedGenerator do
  before :each do
    logger = double(:logger, :info => nil, :level= => nil, :error => nil)
    @tweetfeed_conf = TweetfeedConfig.new logger
    config_file = File.join(Dir.pwd, 'spec/data', 'test_config.yml')
    @tweetfeed_conf.read config_file
    @tweetfeed_generator = TweetfeedGenerator.new @tweetfeed_conf
    @old_rss_xml = File.join(Dir.pwd, 'spec/data', 'old_rss_file.xml')
  end

  it "should parse the xml file to an RSS object" do
    tfg = @tweetfeed_generator
    rss_file = tfg.parse_rss_file @old_rss_xml
    rss_file.should be_an_instance_of RSS::Rss
  end
end

