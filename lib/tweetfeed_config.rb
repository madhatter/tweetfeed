require 'yaml'
require 'logger'

# Class for handling the configuration file
# of tweetfeed

class TweetfeedConfig
  attr_reader :log_level, :hashtags

  def initialize
    @CONFIG_FILE = 'tweetfeed.yml'
    @logger = Logger.new(STDOUT)
    config_file = File.join(Dir.pwd, 'config', @CONFIG_FILE)
    read config_file
  end

  def read config_file
    configuration = YAML.load_file(config_file)
    @logger.info "Config file read..."
    
    @log_level = configuration['loglevel']
    @logger.level = @log_level
    @logger.info "Log level set to #{@log_level}..."

    unless configuration['hashtags'].nil?
      @hashtags = configuration['hashtags'].split(',').collect { |tag| tag.strip } 
      @logger.info "Hashtags found: #{@hashtags}"
    else
      @logger.error "No Hashtags found. Exiting."
      exit
    end
  end
end

