require 'yaml'
require 'logger'

# Class for handling the configuration file
# of tweetfeed

class Tweetfeed_config
  def initialize
    @CONFIG_FILE = 'tweetfeed.yml'
    @logger = Logger.new(STDOUT)
    config_file = File.join(Dir.pwd, 'config', @CONFIG_FILE)
    @configuration = YAML.load_file(config_file)
    
    puts "Heh?!"
    @logger.info "Config file read..."
  end
end

