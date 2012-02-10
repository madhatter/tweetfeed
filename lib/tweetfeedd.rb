require 'daemons'
require 'eventmachine'
require 'logger'

# Class for handling the tweetfeed daemon (tweetfeedd)
class Tweetfeedd
  def run
    Daemons.run_proc('tweetfeedd', :dir_mode => :script, :dir => './', \
                     :backtrace => true, :log_output => true) do
      @logger = Logger.new(STDOUT)
      @logger.info "Starting tweetfeed daemon..."

      EventMachine::run {
        EventMachine::add_periodic_timer(20) {
          @logger.info "Searching..."
          begin
            puts "Here we'll call the tweedfeed class later..."
          rescue InternalServerError
            $stderr.puts "Something went terribly wrong."
          end
        }
      }
    end
  end
end
