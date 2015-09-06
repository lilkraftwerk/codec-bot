require_relative 'codecbot'
require_relative 'custom_twitter'

def run
  snake = MGSTwitter.new
  snake.do_it
  snake.results.each_with_index do |result, index|
    puts "item #{index + 1} of #{snake.results.length}"
    codec = CodecCreator.new(result)
    codec.do_it
  end
end

