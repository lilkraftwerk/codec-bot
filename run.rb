require_relative 'codecbot'
require_relative 'custom_twitter'

def run
  snake = MGSTwitter.new
  snake.do_it
  snake.results.each do |result|
    puts "still running..."
    codec = CodecCreator.new(result)
    codec.do_it
  end
end

