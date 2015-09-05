require 'twitter'
require 'active_support/time'
require 'pry'

require_relative 'keys'

TWITTER_KEY ||= ENV["TWITTER_KEY"]
TWITTER_SECRET ||= ENV["TWITTER_SECRET"]
ACCESS_TOKEN ||= ENV["ACCESS_TOKEN"]
ACCESS_SECRET ||= ENV["ACCESS_SECRET"]

class MGSTwitter
  attr_reader :client, :request_tweets, :profile_image_url, :username

  def initialize
    configure_twitter_client
    @mentions = @client.mentions_timeline
    sort_dms
  end

  def get_tweet_by_id(id)
    @client.status(id)
  end

  def get_tweet_id(url_string)
    regex = /\/status\/(\d+)/
    regex.match(url_string).captures.first
  end

  def has_tweet_id?(url_string)
    regex = /\/status\/(\d+)/
    !regex.match(url_string).nil?
  end

  def get_tweet(id)
    @client.status(id)
  end

  def sort_dms
    @request_tweets = []
    @mentions.each do |tweet|
      if tweet.urls?
        url = tweet.urls.first.expanded_url
        if has_tweet_id?(url)
          id = get_tweet_id(url)
          @request_tweets << get_tweet(id.to_i)
        end
      end
    end
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

  def get_profile_pic
    begin
      image = Magick::ImageList.new
      @profile_image_url.to_s.gsub!('_normal', '')
      urlimage = open(@profile_image_url)
      image.from_blob(urlimage.read)
    rescue OpenURI::HTTPError
      puts "porblem. retrying..."
      retry
    else
      puts "we made it, writing image"
      image.write("tmp/#{@username}.jpg")
    end
  end
end

c = MGSTwitter.new
c.request_tweets.each do |tweet|
  binding.pry
end
tweet = c.request_tweets.first

puts tweet.in_reply_to_screen_name if tweet.in_reply_to_screen_name?

class TweetHandler
  def initialize(tweet)
    @user = tweet.user

  end
end