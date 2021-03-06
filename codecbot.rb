require_relative 'mark'
require_relative 'custom_twitter'

require 'open-uri'
require 'rmagick'
include Magick

require 'action_view'
include ActionView::Helpers::TextHelper

class CodecCreator
  def initialize(options)
    @first_username = options[:first_username]
    @second_username = options[:second_username]
    @tweet_text = options[:tweet_text]
    @client = MGSTwitter.new
    # @markov = MGSMarkov.new
  end

  def do_it
    download_avatars
    create_first_avatar
    create_second_avatar
    format_codec_background
    write_random_text
    puts "done tweetin'"
  end

  def split_text(text)
    word_wrap(text, line_width: 47)
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
    @avatar_one = @avatar_one.adaptive_blur(0.7, 1.0)
    @avatar_two = @avatar_two.adaptive_blur(0.7, 1.0)

    @avatar_one = @avatar_one.blur_image(0.7, 0.7)
    @avatar_two = @avatar_two.blur_image(0.7, 0.7)

    @avatar_one = @avatar_one.scale(0.1).scale(10)
    @avatar_two = @avatar_two.scale(0.1).scale(10)

    @codec_background =  Magick::Image.read("static/emptycodec.png")[0]
    @codec_background.composite!(@avatar_two, 120, 109, Magick::OverCompositeOp)
    @codec_background.composite!(@avatar_one, 955, 107, Magick::OverCompositeOp)
  end

  def write_random_text
    text = Magick::Draw.new
    text.font = "Verdana.ttf"

    unless @tweet_text
      @tweet_text = @markov.make_sentence
    end

    new_text = @tweet_text.gsub(/https?:\/\/[\S]+/, '')

    split_sentence = split_text(new_text)

    text.annotate(@codec_background, 100, 100, 175, 525, split_sentence) {
            self.fill = 'white'
            self.pointsize = 36
            self.gravity = Magick::WestGravity
        }

    text_to_tweet = "dril in conversation with @#{@first_username}"

    filename = "tmp/#{rand(10000)}.png"
    @codec_background.write(filename)

    File.open(filename) do |f|
      puts "locally #{filename}"
      puts "upload commented out"
      @client.update(text_to_tweet, f)
    end
  end
end
