require 'logger'
require 'rss/maker'
require 'rss/2.0'

require_relative '../lib/tweetfeed_config.rb'
require_relative '../lib/tweetfeed_url_parser.rb'

class TweetfeedGenerator
  PWD = File.dirname(File.expand_path(__FILE__))
  BACKUP_FILE = File.join(PWD, '../', '.tweetfeed.xml')
  LOCATION_START = 'Location: '
  LOCATION_STOP  = "\r\n"

  def initialize config
    @config = config
    @rss_outfile = config.rss_outfile
    @backup_file = BACKUP_FILE

    @logger = Logger.new(STDOUT)
    @logger.level = @config.log_level
    @url_parser = UrlParser.new @config
  end

  def generate_rss_file tweets
    old_items = parse_rss_file @backup_file
    generate_rss_feed(tweets, old_items)
  end

  # Parse the default backup rss file to be able to combine the old items with the new ones
  def parse_rss_file backup_file
    xml_file = backup_file
    @logger.info "Parsing old feed items from " + xml_file
    content = ""
    begin
      open(xml_file) { |f| content = f.read }
    rescue Exception
      @logger.error "Backup file is not where I thought it should be."
    end
    RSS::Parser.parse(content, false) unless content.empty?
  end

  # Generate the final xml file
  def generate_rss_feed tweets, old_items
    version = "2.0"
    long_url = nil

    @logger.info "Generating RSS feed to #{@rss_outfile}."

    content = RSS::Maker.make(version) do |m|
      m.channel.title = "tweetfeed RSS feed #{@hashtags}"
      m.channel.link = "http://github.com/madhatter/tweetfeed"
      m.channel.description = "Automatically generated news from Twitter hashtags"
      m.items.do_sort = true # sort items by date

      tweets.each do |tweet|
        orig_url = tweet.urls[0].url
        expanded_url = tweet.urls[0].expanded_url
        @logger.debug "URL to fetch: #{orig_url}"
        @logger.debug "Already expanded url: #{expanded_url}"
        short_url = expanded_url
        title = tweet['text'].sub(/(#{orig_url})/, "")
        long_url = @url_parser.get_original_url short_url

        # TODO: Maybe some kind of domain filter would be nice here...
        i = m.items.new_item
        i.title = title.gsub(/\n/,"")
        #i.link = tweet['attrs']['entities']['urls'][0]['url']
        unless long_url == nil
          i.link = long_url.gsub(/\r/,"")
        else
          i.link = orig_url.gsub(/\r/,"") unless orig_url == nil
        end
        i.date = tweet['created_at']
      end

      @logger.debug "Adding the old stuff...:"
      old_items.items.each do |item|
        i = m.items.new_item
        i.title = item.title
        @logger.debug "Adding item '#{item.title}'"
        i.link = item.link
        i.date = item.date
      end unless old_items.nil?
    end
    save_rss_feed(content)
  end

  # Saving the final xml file and creating the backup file
  def save_rss_feed content
    File.open(@rss_outfile, "w") do |file|
      file.write(content)
    end

    File.open(@backup_file, "w") do |file|
      file.write(content)
    end
  end
end
