require_relative 'mark'
require_relative 'custom_twitter'
require_relative 'utilities'

require 'active_support/time'
require 'open-uri'
require 'rmagick'
include Magick

class CodecBot
  def initialize
    @client = GarfTwitter.new
  end

  def create_codec_image

  end

  def create_background_image

  end

end

def less_than_ten_minutes_old(tweet)
  ten_minutes_ago = Time.now.getlocal('+00:00') - 10.minutes
  tweet.created_at > ten_minutes_ago
end

tweets_to_do = []

    # avatar_one = Magick::Image.read("tmp/#{rand(7)}test.jpg")[0]


class ImagesFromTweet
  def initialize

  end

  def create_first_avatar
    @avatar_one = create_avatar()
  end

  def create_second_avatar

  end

  def construct_codec
    codec_background = Magick::Image.read("emptycodec.png")[0]
    codec_background.composite!(avatar_two, 112, 109, Magick::OverCompositeOp)
    codec_background.composite!(avatar_one, 955, 107, Magick::OverCompositeOp)

    text = Magick::Draw.new
    text.font = "Verdana.ttf"

    # new_text = split_text(tweet.text)
    # new_text.gsub!("\n ", "\n")
  end

  def create_avatar(filename)
    avatar = Magick::Image.read(filename)[0]
    avatar = avatar.resize_to_fill(225, 367)

    green = Magick::Image.new(225, 367) { self.background_color = "green" }
    green.opacity = (Magick::QuantumRange * 0.5).floor
    green.quantum_operator(MultiplyQuantumOperator, 0.9, AlphaChannel)

    avatar.composite!(green, 0, 0, Magick::OverCompositeOp)
    avatar = avatar.adaptive_blur(0.5, 1.0)

    return avatar
  end

end

g = GarfTwitter.new
g.get_tweets('dril')
t = g.tweets

tweets_to_do << t.shuffle.shift










tweets_to_do.each do |tweet|
  puts "looping #{tweet}"
  new_background = codec_background


  new_background.write "result.png"

  File.open('result.png') do |f|
    twitter_client.update(tweet.url, f)
  end
end



# make it like so that you can dm a link to a tweet as long as it's a reply