require_relative 'mark'
require 'rmagick'
include Magick

m = MGSMarkov.new
s = m.make_sentence

s = s.join(' ')
# print s

# snake = Magick::Image.read("tmp/snake.png")[0]

snake = Magick::Image.read("dril.jpeg")[0]
snake = snake.resize_to_fill(225, 367)
green = Magick::Image.new(225, 367) { self.background_color = "green" }
green.opacity = (Magick::QuantumRange * 0.3).floor
green.quantum_operator(MultiplyQuantumOperator, 0.4, AlphaChannel)

snake.composite!(green, 0, 0, Magick::OverCompositeOp)

other = Magick::Image.read("tmp/#{rand(7)}test.jpg")[0]
other = other.resize_to_fill(222, 367)
other.write('doge.png')



codec_pic =  Magick::Image.read("emptycodec.png")[0]
codec_pic.composite!(other, 112, 109, Magick::OverCompositeOp)
codec_pic.composite!(snake, 955, 107, Magick::OverCompositeOp)


codec_pic.write "result.png"