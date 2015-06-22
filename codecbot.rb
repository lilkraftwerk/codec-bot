require_relative 'mark'
require_relative 'custom_twitter'

require 'open-uri'
require 'rmagick'
include Magick



def get_profile_pic(client)
  begin
    url = client.profile_image_url
    image = Magick::ImageList.new
    puts url
    url.to_s.gsub!('_normal', '')

    urlimage = open(url)
    image.from_blob(urlimage.read)
  rescue OpenURI::HTTPError
    puts "porblem. retrying..."
    retry
  else
    puts "we made it, writing image"
    image.write("tmp/profilepic.jpg")
  end
end

m = MGSMarkov.new
s = m.make_sentence

t = GarfTwitter.new
t.get_tweets('kimkierkegaard')
tweets = t.tweets

# puts tweets.first.user.methods
get_profile_pic(t)


tweet_array = []
tweets.each do |tweet|
  tweet_array << tweet.text if !tweet.retweet?
end

chosen = tweet_array.sample

puts tweet_array

s = s.join(' ')

# snake = Magick::Image.read("tmp/snake.png")[0]

snake = Magick::Image.read("tmp/profilepic.jpg")[0]
snake = snake.resize_to_fill(225, 367)
green = Magick::Image.new(225, 367) { self.background_color = "green" }
green.opacity = (Magick::QuantumRange * 0.5).floor
green.quantum_operator(MultiplyQuantumOperator, 0.9, AlphaChannel)

snake.composite!(green, 0, 0, Magick::OverCompositeOp)

other = Magick::Image.read("tmp/#{rand(7)}test.jpg")[0]
other = other.resize_to_fill(222, 367)
other.write('doge.png')

snake = snake.adaptive_blur(0.5, 1.0)

codec_pic =  Magick::Image.read("emptycodec.png")[0]
codec_pic.composite!(other, 112, 109, Magick::OverCompositeOp)
codec_pic.composite!(snake, 955, 107, Magick::OverCompositeOp)

sentence = "oculus allows you to smoke wii remote like a cigar and\nblow heaps of smoke in celebs faces"

text = Magick::Draw.new
text.font = "Verdana.ttf"

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
  p new_array.join(' ')
  new_array.join(' ')
end

chosen = split_text(chosen)
chosen.gsub!("\n ", "\n")

text.annotate(codec_pic, 100, 100, 175, 555, chosen) {
        self.fill = 'white'
        self.pointsize = 36
        self.gravity = Magick::WestGravity
    }

codec_pic.write "result.png"
