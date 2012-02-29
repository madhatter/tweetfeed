require_relative '../lib/tweetfeed_config.rb'
require_relative '../lib/tweetfeed.rb'

describe Tweetfeed do
  before :each do
    @tweetfeed_conf = TweetfeedConfig.new
    config_file = File.join(Dir.pwd, 'spec', 'test_config.yml')
    @tweetfeed_conf.read config_file
    @twitter = stub :search => {:hashtag => 'bla', :id => '13'}
  end

  it "should not crash" do
    @tweetfeed = Tweetfeed.new @tweetfeed_conf
    @tweetfeed.twitter = @twitter
    res = @tweetfeed.search
    #puts res
  end
end
