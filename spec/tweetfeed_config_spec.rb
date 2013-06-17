require_relative '../lib/tweetfeed_config.rb'
require 'yaml'
require 'spec_helper.rb'
require 'twitter'

describe TweetfeedConfig do
  before :each do
    logger = double(:logger, :info => nil, :level= => nil)
    @tweetfeed_conf = TweetfeedConfig.new logger
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

  it "should save an updated last_id" do
    config = @tweetfeed_conf
    config.last_id = 12
    config.write

    config.read
    response = config.last_id
    response.should == 12
  end
end

describe Twitter do
  describe "user_info" do
    it "should get extended user information" do
      # create canned_response file like that:
      #  curl -is 'https://api.twitter.com/1.1/users/show.json?screen_name=nostalgix' --header 'Authorization: OAuth oauth_consumer_key="mtcWEpAwDQBpBir09amY7Q", oauth_nonce="317014a3bd0d3e8ff6e9e2c0e6ac2187", oauth_signature="zjf%2Fkiq8l3TO9YqXeESPMYahfY0%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1371498564", oauth_token="12879982-hlQ5e5hMaJ3js7sAn64VvE4YJXVeURDCBOMAK6MSW", oauth_version="1.0"' -D test.json

      canned_response = File.new File.join(Dir.pwd, 'spec', 'canned_response.json')
      stub_request(:get, "https://api.twitter.com/1.1/users/show.json?screen_name=nostalgix").to_return(canned_response)
 
      Twitter.user('nostalgix')['name'].should == "madhatter"
    end
  end
end
