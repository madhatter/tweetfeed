require_relative '../lib/tweetfeed_config.rb'
require 'yaml'

describe Tweetfeed_config do
  before :each do
    @tweetfeed_conf = Tweetfeed_config.new
    config_file = File.join(Dir.pwd, 'test_config.yml')
  end
end
