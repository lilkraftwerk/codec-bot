require_relative 'mark'
require_relative 'custom_twitter'
require_relative 'utilities'
require 'active_support/time'
require 'open-uri'
require 'rmagick'
include Magick

twitter_client = GarfTwitter.new

def less_than_ten_minutes_old(tweet)
  ten_minutes_ago = Time.now.getlocal('+00:00') - 10.minutes
  tweet.created_at > ten_minutes_ago
end



tweets_to_do = []

g = GarfTwitter.new
g.get_tweets('dril')
t = g.tweets
# t.each do |tweet|
#   tweets_to_do << tweet if less_than_ten_minutes_old(tweet) && tweet.text.length > 1
# end

tweets_to_do << t.shuffle.shift


avatar_one = Magick::Image.read("dril.jpeg")[0]
# avatar_one = Magick::Image.read("tmp/#{rand(7)}test.jpg")[0]
avatar_one = avatar_one.resize_to_fill(225, 367)

green = Magick::Image.new(225, 367) { self.background_color = "green" }
green.opacity = (Magick::QuantumRange * 0.5).floor
green.quantum_operator(MultiplyQuantumOperator, 0.9, AlphaChannel)

avatar_one.composite!(green, 0, 0, Magick::OverCompositeOp)

green2 = Magick::Image.new(225, 367) { self.background_color = "green" }
green2.opacity = (Magick::QuantumRange * 0.5).floor
green2.quantum_operator(MultiplyQuantumOperator, 0.9, AlphaChannel)

avatar_two = Magick::Image.read("tmp/#{rand(7)}test.jpg")[0]
# avatar_two = Magick::Image.read("dril.jpeg")[0]
avatar_two = avatar_two.resize_to_fill(222, 367)

avatar_two.composite!(green2, 0, 0, Magick::OverCompositeOp)

avatar_one = avatar_one.adaptive_blur(0.5, 1.0)
avatar_two = avatar_two.adaptive_blur(0.5, 1.0)

codec_background =  Magick::Image.read("emptycodec.png")[0]
codec_background.composite!(avatar_two, 112, 109, Magick::OverCompositeOp)
codec_background.composite!(avatar_one, 955, 107, Magick::OverCompositeOp)

text = Magick::Draw.new
text.font = "Verdana.ttf"

tweets_to_do.each do |tweet|
  puts "looping #{tweet}"
  new_background = codec_background
  new_text = split_text(tweet.text)
  new_text.gsub!("\n ", "\n")
  text.annotate(new_background, 100, 100, 175, 550, new_text) {
        self.fill = 'white'
        self.pointsize = 36
        self.gravity = Magick::WestGravity
    }
  new_background.write "result.png"

  File.open('result.png') do |f|
    twitter_client.update(tweet.url, f)
  end
end



# make it like so that you can dm a link to a tweet as long as it's a reply