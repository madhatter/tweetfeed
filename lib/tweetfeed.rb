require 'twitter'
require 'curb'
require 'logger'
require 'rss/maker'
require 'rss/2.0'

require_relative '../lib/tweetfeed_config.rb'

class Tweetfeed
  LOCATION_START = 'Location: '
  LOCATION_STOP  = "\r\n"
  PWD = File.dirname(File.expand_path(__FILE__))
  BACKUP_FILE = File.join(PWD, '../', '.tweetfeed.xml')

  def initialize(config)
    @config = config
    @log_level = config.log_level
    @hashtags = config.hashtags
    @last_id = config.last_id
    @rss_outfile = config.rss_outfile

    @logger = Logger.new(STDOUT)
    @logger.level = @log_level
    @twitter = Twitter::Client.new
  end

  # Starts the search and generates the RSS feed file.
  def run
    @logger.debug "LastId is " +@last_id.to_s
    tweets = search
    old_items = parse_rss_file
    generate_rss_feed(tweets, old_items) if tweets
    #
    # the last thing we do:
    @config.write
    @logger.info "....and we are done.\n\n"
  end

  # Search for hashtags at Twitter
  def search
    result = []
    begin
      @hashtags.each do |hashtag|
        result = @twitter.search("##{hashtag} -rt", :since_id => @last_id, :include_entities => 1)
      end

      store_last_id calculate_last_id result
      filter_tweets_with_urls result

    rescue EOFError, SocketError
      @logger.error "Connection to Twitter seems to be not available."
    end
  end

  # Get the max tweet id from the last search result
  def calculate_last_id tweets
    last_id = @last_id
    tweets.each do |t| 
      last_id = t['id'] if t['id'] > last_id 
    end
    last_id
  end

  # Store the tweet id from the latest search in the configuration
  def store_last_id last_id
    @config.last_id = last_id
    @last_id = @config.last_id
  end

  # Filter the tweets for tweets with URLs only.
  def filter_tweets_with_urls tweets
    tweets_with_urls = []
    tweets.each do |tweet|
      tweets_with_urls << tweet unless tweet['attrs']['entities']['urls'].empty?
    end
    tweets_with_urls
  end

  # Parse the default backup rss file to be able to combine the old items with the new ones
  def parse_rss_file
    xml_file = BACKUP_FILE
    @logger.info "Parsing old feed items from " + xml_file
    content = ""
    begin
      open(xml_file) { |f| content = f.read }
    rescue Exception
      @logger.error "Backup file is not where I thought it should be."
    end
    rss = RSS::Parser.parse(content, false) unless content.empty?
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
        orig_url = tweet['attrs']['entities']['urls'][0]['expanded_url']
        @logger.debug "URL to fetch: #{orig_url}"
        short_url = orig_url
        title = tweet['text'].sub(/(#{orig_url})/, "") 
        long_url = get_original_url(short_url)
        @logger.debug "Found: #{long_url}"
        i = 1
        while short_url != long_url do
          @logger.debug "Curling #" + i.to_s
          short_url = long_url
          long_url = get_original_url(short_url)
          @logger.debug "Found: #{long_url}"
          i +=1
          break if long_url == short_url
        end

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

    File.open(BACKUP_FILE, "w") do |file|
      file.write(content)
    end
  end

  # Get the long/original URL
  def get_original_url short_url
    try = 0
    resp = 'empty'
    begin
      @logger.debug short_url.class
      resp = Curl::Easy.http_get(short_url) { |res| res.follow_location = true }
      @logger.debug resp.response_code
    rescue => err
      @logger.error "Curl::Easy.http_get failed: #{err}"
      try += 1
      sleep 3
      if try < 5
        retry
      else 
        return nil
      end
    end

    @logger.debug resp.response_code
    @logger.debug "#{resp.header_str}"
    if(resp && resp.header_str.index(LOCATION_START) \
       && resp.header_str.index(LOCATION_STOP))
      start = resp.header_str.index(LOCATION_START) + LOCATION_START.size
      stop = resp.header_str.index(LOCATION_STOP, start)
      @logger.debug "Get redirect link"
      resp.header_str[start..stop]
    else
      @logger.debug "Not getting redirect link for #{short_url}"
      # return the old one instead, better than nothing
      short_url
    end
  end
end

