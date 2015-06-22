require_relative 'mark'
require_relative 'custom_twitter'
require_relative 'utilities'

require 'open-uri'
require 'rmagick'
include Magick

first_username = 'dril'
second_username = 'nah_solo'

markov = MGSMarkov.new
s = m.make_sentence
s = s.join(' ')

t = GarfTwitter.new
# t.get_tweets(first_username)
first_url = GarfTwitter.get_url(first_username)
second_url = GarfTwitter.get_url(second_username)

get_profile_pic(first_url, first_username)
get_profile_pic(second_url, second_username)

# snake = Magick::Image.read("tmp/snake.png")[0]

avatar_one = Magick::Image.read("tmp/#{first_username}1.jpg")[0]
avatar_one = avatar_one.resize_to_fill(225, 367)

green = Magick::Image.new(225, 367) { self.background_color = "green" }
green.opacity = (Magick::QuantumRange * 0.5).floor
green.quantum_operator(MultiplyQuantumOperator, 0.9, AlphaChannel)

avatar_one.composite!(green, 0, 0, Magick::OverCompositeOp)

green2 = Magick::Image.new(225, 367) { self.background_color = "green" }
green2.opacity = (Magick::QuantumRange * 0.5).floor
green2.quantum_operator(MultiplyQuantumOperator, 0.9, AlphaChannel)

# avatar_two = Magick::Image.read("tmp/#{rand(7)}test.jpg")[0]
avatar_two = Magick::Image.read("tmp/#{second_username}.jpg")[0]
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
s.gsub!("\n ", "\n")

text.annotate(codec_background, 100, 100, 175, 500, s) {
        self.fill = 'white'
        self.pointsize = 36
        self.gravity = Magick::WestGravity
    }

codec_pic.write "result.png"
