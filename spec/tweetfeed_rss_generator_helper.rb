require_relative '../lib/tweetfeed_rss_generator.rb'

class TweetfeedGeneratorTestHelper < TweetfeedGenerator
  PWD = File.dirname(File.expand_path(__FILE__))
  BACKUP_FILE = File.join(PWD, './data', 'backup_file') 

  attr_accessor :rss_outfile, :backup_file

  def initialize config
    super config
    @backup_file = BACKUP_FILE
  end

  def delete_test_output_files 
    File.delete(BACKUP_FILE) if File.exists? BACKUP_FILE
    File.delete(@rss_outfile) if File.exists? @rss_outfile
  end
end
