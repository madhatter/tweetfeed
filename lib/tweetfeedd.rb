require 'daemons'
require 'eventmachine'
require 'logger'

require_relative '../lib/tweetfeed_config.rb'
require_relative '../lib/tweetfeed.rb'

# Class for handling the tweetfeed daemon (tweetfeedd)
class Tweetfeedd
  def run
    Daemons.run_proc('tweetfeedd', :dir_mode => :script, :dir => './', \
                     :backtrace => true, :log_output => true) do
      @logger = Logger.new(STDOUT)
      @logger.info "Starting tweetfeed daemon..."

      @config = TweetfeedConfig.new
      @tweetfeed = Tweetfeed.new(@config)

      EventMachine::run {
        EventMachine::add_periodic_timer(20) {
          @logger.info "Searching..."
          begin
            @tweetfeed.run
          rescue InternalServerError
            $stderr.puts "Something went terribly wrong."
          end
        }
      }
    end
  end
end
