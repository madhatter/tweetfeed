require 'spec_helper.rb'
require 'yaml'
require 'rss/2.0'
require_relative '../lib/tweetfeed_config.rb'
require_relative './tweetfeed_rss_generator_helper.rb'

describe TweetfeedGenerator do
  before :each do
    logger = double(:logger, :info => nil, :level= => nil, :error => nil)
    @tweetfeed_conf = TweetfeedConfig.new logger
    config_file = File.join(Dir.pwd, 'spec/data', 'test_config.yml')
    @tweetfeed_conf.read config_file
    @tweetfeed_generator = TweetfeedGeneratorTestHelper.new @tweetfeed_conf
    @old_rss_xml = File.join(Dir.pwd, 'spec/data', 'old_rss_file.xml')

    @tweetfeed_generator.rss_outfile = File.join(Dir.pwd, 'spec/data', 'rss_output_file')
    @tweetfeed_generator.delete_test_output_files
  end

  it "should always raise an error when there are no hashtags defined" do
    config = @tweetfeed_conf
    config_file = File.join(Dir.pwd, 'spec', 'test_config_no_hashtags.yml')
    lambda {config.read config_file}.should raise_error
  end

  it "should parse the xml file to an RSS object" do
    tfg = @tweetfeed_generator
    rss_file = tfg.parse_rss_file @old_rss_xml
    rss_file.should be_an_instance_of RSS::Rss
  end

  it "should save the feed to two directories" do
    tfg = @tweetfeed_generator
    tfg.save_rss_feed tfg.parse_rss_file(@old_rss_xml)
    File.exist?(tfg.backup_file).should be_true 
    File.exist?(tfg.rss_outfile).should be_true 
  end
end

