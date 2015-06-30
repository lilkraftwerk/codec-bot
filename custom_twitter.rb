require 'twitter'
require 'active_support/time'

require_relative 'keys'

TWITTER_KEY ||= ENV["TWITTER_KEY"]
TWITTER_SECRET ||= ENV["TWITTER_SECRET"]
ACCESS_TOKEN ||= ENV["ACCESS_TOKEN"]
ACCESS_SECRET ||= ENV["ACCESS_SECRET"]

class GarfTwitter
  attr_reader :tweets, :profile_image_url, :username

  def initialize
    configure_twitter_client
  end

  def get_friends
    @client.followers('nah_solo')
  end

  def configure_twitter_client
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = TWITTER_KEY
      config.consumer_secret = TWITTER_SECRET
      config.access_token = ACCESS_TOKEN
      config.access_token_secret = ACCESS_SECRET
    end
  end

  def update(text, file)
    @client.update_with_media(text,file)
  end

  def get_tweets(username)
    @tweets = @client.user_timeline(username)
    @username = username
    @profile_image_url = @tweets.first.user.profile_image_url
  end

  def get_url(username)
    @client.user(username).profile_image_url
  end

 def update(text, file)
    @client.update_with_media(text,file)
  end

end

def get_profile_pic(url, username)
  begin
    image = Magick::ImageList.new
    url.to_s.gsub!('_normal', '')
    urlimage = open(url)
    image.from_blob(urlimage.read)
  rescue OpenURI::HTTPError
    puts "porblem. retrying..."
    retry
  else
    puts "we made it, writing image"
    image.write("tmp/#{username}.jpg")
  end
end

