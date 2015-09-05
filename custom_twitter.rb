require 'twitter'
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

  def get_mentions
    @mentions = @client.mentions_timeline
  end

  def select_mentions_less_than_an_hour_old
    @mentions = @mentions.select do |mention|
      mention.created_at > 1.hour.ago
    end
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
          requester = tweet.user.screen_name
          id = get_tweet_id(url)
          @results << {
            url: url,
            tweet: get_tweet(id.to_i),
            first_username: requester
          }
        end
      end
    end
  end

  def format_results
    @results.each do |result|
      second_user = result[:tweet].user.screen_name
      text = result[:tweet].text
      result[:second_username] = second_user
      result[:tweet_text] = text
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