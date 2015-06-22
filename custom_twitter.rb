require 'twitter'
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

  def configure_twitter_client


    client = Twitter::REST::Client.new do |config|
      config.consumer_key = TWITTER_KEY
      config.consumer_secret = TWITTER_SECRET
      config.access_token = ACCESS_TOKEN
      config.access_token_secret = ACCESS_SECRET
    end
    @client = client
  end

  def update(text, file)
    @client.update_with_media(text,file)
  end

  def get_tweets(username)
    @tweets = @client.user_timeline(username)
    @username = username
    @profile_image_url = @tweets.first.user.profile_image_url
  end

  def get_methods
    @client.friends('nah_solo').each do |x|
      puts x.username
    end
    # puts @tweets.first.methods
    # @tweets.each do |tweet|
      # puts "#retweet: #{tweet.retweet?}"
      # puts "reply: #{tweet.reply?}"
    # end
  end
end


g = GarfTwitter.new
g.get_tweets('dril')
g.get_methods
