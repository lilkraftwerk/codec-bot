require_relative 'mark'
require_relative 'custom_twitter'
require_relative 'utilities'

require 'open-uri'
require 'rmagick'
include Magick

class CodecCreator
  def initialize(options)
    @first_username = options[:first_username]
    @second_username = options[:second_username]
    @tweet = options[:tweet]
    @client = MGSTwitter.new
    @markov = MGSMarkov.new
  end

  def do_it
    download_avatars
    create_first_avatar
    create_second_avatar
    format_codec_background
    write_random_text
    puts "swag me the fuck out"
  end

  def split_text(text)
    split = 47
    orig_array = text.split(' ')
    new_array = []
    while orig_array.length > 0
      new_array << orig_array.shift
      if new_array.join(' ').length > split
        new_array.push("\n")
        split += 47
      end
    end
    new_array.join(' ')
  end

  def download_avatars
    @avatar_1_location = @client.download_avatar(@first_username)
    puts @avatar_1_location
    @avatar_2_location = @client.download_avatar(@second_username)
    puts @avatar_2_location
  end

  def create_first_avatar
    @avatar_one = Magick::Image.read(@avatar_1_location)[0]
    @avatar_one = @avatar_one.resize_to_fill(225, 367)

    green = Magick::Image.new(225, 367) { self.background_color = "green" }
    green.opacity = (Magick::QuantumRange * 0.5).floor
    green.quantum_operator(MultiplyQuantumOperator, 0.9, AlphaChannel)

    @avatar_one.composite!(green, 0, 0, Magick::OverCompositeOp)
  end

  def create_second_avatar
    @avatar_two = Magick::Image.read(@avatar_2_location)[0]
    @avatar_two = @avatar_two.resize_to_fill(222, 367)

    green = Magick::Image.new(225, 367) { self.background_color = "green" }
    green.opacity = (Magick::QuantumRange * 0.5).floor
    green.quantum_operator(MultiplyQuantumOperator, 0.9, AlphaChannel)

    @avatar_two.composite!(green, 0, 0, Magick::OverCompositeOp)
  end

  def format_codec_background
    @avatar_one = @avatar_one.adaptive_blur(0.5, 1.0)
    @avatar_two = @avatar_two.adaptive_blur(0.5, 1.0)

    @codec_background =  Magick::Image.read("emptycodec.png")[0]
    @codec_background.composite!(@avatar_one, 112, 109, Magick::OverCompositeOp)
    @codec_background.composite!(@avatar_two, 955, 107, Magick::OverCompositeOp)
  end

  def write_random_text
    text = Magick::Draw.new
    text.font = "Verdana.ttf"

    # word wrap for tweets
    # chosen = split_text(chosen)
    # chosen.gsub!("\n ", "\n")
    s = @markov.make_sentence
    split_sentence = split_text(s)


    text.annotate(@codec_background, 100, 100, 175, 550, split_sentence) {
            self.fill = 'white'
            self.pointsize = 36
            self.gravity = Magick::WestGravity
        }

    @codec_background.write "results/#{rand(10000)}.png"
  end
end

options = {
  first_username: 'dril',
  second_username: 'nah_solo'
}

codec = CodecCreator.new(options)
codec.do_it
# s = markov.make_sentence
# s = s.join(' ')

# t.get_tweets(first_username)

# snake = Magick::Image.read("tmp/snake.png")[0]

# all_tweets = []
# twitter_client.get_tweets('dril')
# tweets = twitter_client.tweets
# puts tweets.first.metadata
# tweets.each do |tweet|
  # p tweet
  # p tweet.text
  # all_tweets << tweet.text if !tweet.retweet? && !tweet.reply?
# end

# puts tweets.first.metadata
# puts tweets.first.created_at





#