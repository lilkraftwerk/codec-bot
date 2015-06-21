require_relative 'mark'
require 'rmagick'
include Magick

m = MGSMarkov.new
s = m.make_sentence

s = s.join(' ')
# print s

start_x = 0
start_y_top = 0
start_y_bottom = 153

counter = 0

4.times do |x|
  pix = Magick::Image.read("pix.png")[0]
  dog = pix.crop(start_x, start_y_bottom, 125, 153)
  start_x += 125
  dog.write("tmp/#{counter}test.jpg")
  counter += 1

end

start_x = 0

4.times do |x|
  pix = Magick::Image.read("pix.png")[0]
  dog = pix.crop(start_x, start_y_top, 125, 153)
  start_x += 125
  dog.write("tmp/#{counter}test.jpg")
  counter += 1

end