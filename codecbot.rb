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
    @tweet_text = options[:tweet_text]
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

  def get_tweet_text

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

    unless @tweet_text
      @tweet_text = @markov.make_sentence
    end

    split_sentence = split_text(@tweet_text)

    text.annotate(@codec_background, 100, 100, 175, 550, split_sentence) {
            self.fill = 'white'
            self.pointsize = 36
            self.gravity = Magick::WestGravity
        }

    filename = "results/#{rand(10000)}.png"
    @codec_background.write(filename)
    File.open(filename) do |f|
      @client.update('text', f)
  end
  end
end


# options = {
  # first_username: names.shift,
  # second_username: names.shift,
  # tweet_text: "actually, im not mad. youre the one who is mad. this isf unny to me"
# }



m = MGSTwitter.new
m.get_mentions
m.sort_dms
m.format_results
m.results.each do |result|
  codec = CodecCreator.new(result)
  codec.do_it
end