require_relative 'mark'
require_relative 'custom_twitter'
require_relative 'utilities'

require 'open-uri'
require 'rmagick'
include Magick

twitter_client = MGSTwitter.new
markov = MGSMarkov.new

names = %w( dril nah_solo potus flotus vogon )

first_username = 'potus'
second_username = 'flotus'

# first_username = 'nah_solo'
# second_username = 'dril'

s = markov.make_sentence
s = s.join(' ')

# t.get_tweets(first_username)
first_url = twitter_client.get_url(first_username)
second_url = twitter_client.get_url(second_username)

get_profile_pic(first_url, first_username)
get_profile_pic(second_url, second_username)

# snake = Magick::Image.read("tmp/snake.png")[0]

all_tweets = []
twitter_client.get_tweets('dril')
tweets = twitter_client.tweets
puts tweets.first.metadata
tweets.each do |tweet|
  p tweet
  p tweet.text
  all_tweets << tweet.text if !tweet.retweet? && !tweet.reply?
end

puts tweets.first.metadata
puts tweets.first.created_at

s = all_tweets.shuffle.shift

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

# word wrap for tweets
# chosen = split_text(chosen)
# chosen.gsub!("\n ", "\n")

s = split_text(s)


text.annotate(codec_background, 100, 100, 175, 550, s) {
        self.fill = 'white'
        self.pointsize = 36
        self.gravity = Magick::WestGravity
    }

codec_background.write "result.png"
