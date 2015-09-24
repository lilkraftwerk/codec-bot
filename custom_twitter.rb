require 'twitter'
require 'active_support'
require 'active_support/time'
require 'pry'

require_relative 'keys'

TWITTER_KEY ||= ENV["TWITTER_KEY"]
TWITTER_SECRET ||= ENV["TWITTER_SECRET"]
ACCESS_TOKEN ||= ENV["ACCESS_TOKEN"]
ACCESS_SECRET ||= ENV["ACCESS_SECRET"]

class MGSTwitter
  attr_reader :client, :request_tweets, :profile_image_url, :username, :results

  def initialize
    configure_twitter_client
    @results = []
  end

  def do_it
    get_dril_tweets
    select_tweets_less_than_ten_minutes_old
    remove_replies_and_retweets
    get_followers
    pick_one_follower
    format_tweets
  end

  def format_tweets
    @tweets.each do |tweet|
      @results << {
        first_username: pick_one_follower[:screen_name],
        second_username: 'dril',
        tweet_text: tweet.text
      }
    end
  end

  def select_tweets_less_than_ten_minutes_old
    @tweets = @tweets.select do |mention|
      mention.created_at >= 10.minutes.ago
    end
  end

  def remove_replies_and_retweets
    @tweets = @tweets.select do |tweet|
      !tweet.reply? && !tweet.retweet?
    end
  end

  def select_tweets_less_than_ten_days_old
    @tweets = @tweets.select do |mention|
      mention.created_at >= 10.days.ago
    end
  end

  def get_dril_tweets
    @tweets = @client.user_timeline("dril")
  end

  def get_followers
    @followers = @client.followers
  end

  def pick_one_follower
    users = @followers.attrs[:users]
    rando = rand(users.length)
    users[rando]
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

  def download_avatar(username)
    url = get_url(username)
    image_location = get_profile_pic(url, username)
    image_location
  end

  def get_url(username)
    @client.user(username).profile_image_url
  end

  def get_profile_pic(profile_image_url, username)
    begin
      image = Magick::ImageList.new
      profile_image_url.to_s.gsub!('_normal', '')
      urlimage = open(profile_image_url)
      image.from_blob(urlimage.read)
    rescue OpenURI::HTTPError
      puts "porblem. retrying..."
      retry
    else
      puts "we made it, writing image"
      image.write("tmp/#{username}.jpg")
      "tmp/#{username}.jpg"
    end
  end
end
