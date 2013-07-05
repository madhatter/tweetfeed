require 'spec_helper.rb'
require 'twitter'

describe Twitter do
  describe "user_info" do
    it "should get extended user information" do
      # create canned_response file like that:
      #  curl -is 'https://api.twitter.com/1.1/users/show.json?screen_name=nostalgix' --header 'Authorization: OAuth oauth_consumer_key="mtcWEpAwDQBpBir09amY7Q", oauth_nonce="317014a3bd0d3e8ff6e9e2c0e6ac2187", oauth_signature="zjf%2Fkiq8l3TO9YqXeESPMYahfY0%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1371498564", oauth_token="12879982-hlQ5e5hMaJ3js7sAn64VvE4YJXVeURDCBOMAK6MSW", oauth_version="1.0"' -D test.json

      nostalgix_user_info = File.new File.join(Dir.pwd, 'spec/data', 'nostalgix_user_info.json')
      stub_request(:get, "https://api.twitter.com/1.1/users/show.json?screen_name=nostalgix").to_return(nostalgix_user_info)
 
      Twitter.user('nostalgix')['name'].should == "madhatter"
    end
  end
end
