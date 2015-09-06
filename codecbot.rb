require_relative 'mark'
require_relative 'custom_twitter'
require_relative 'utilities'


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
    @url = options[:url]
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

    @codec_background =  Magick::Image.read("emptycodec.png")[0]
    @codec_background.composite!(@avatar_two, 120, 109, Magick::OverCompositeOp)
    @codec_background.composite!(@avatar_one, 955, 107, Magick::OverCompositeOp)
  end

  def write_random_text
    text = Magick::Draw.new
    text.font = "Verdana.ttf"
    # text.font = "VCR.ttf"
    # text.font = "pixel.TTF"

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

    @url ||= "UNKNOWN URL"
    text_to_tweet = "#{@url}\nrequested by @#{@first_username}"

    filename = "results/#{rand(10000)}.png"
    @codec_background.write(filename)


    # tries to pixelate text
    # top = @codec_background.crop(0,0,1280,400)
    # bottom = @codec_background.crop(0, 400, 1280, 320)
    # pixel_amount = 0.9
    # bottom = bottom.scale(10 / pixel_amount).scale(10 * pixel_amount)
    # top.write('top')
    # bottom.write('bottom')
    # i = Magick::ImageList.new('top', 'bottom').append(true)
    # i.write(filename)

    File.open(filename) do |f|
      puts "locally #{filename}"
      @client.update(text_to_tweet, f)
  end
  end
end


# uncomment and it all works
m = MGSTwitter.new
m.get_mentions
m.select_mentions_less_than_an_hour_old
m.sort_dms
m.format_results
m.results.each do |result|
  codec = CodecCreator.new(result)
  codec.do_it
end

