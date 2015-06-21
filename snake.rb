
file = File.open('snake.txt', 'r')

quotes = {doge: 'cat'}

read = file.read

read.gsub!(/.+\s+:/, '')
read.gsub!("\n", '')



File.open('output2.txt', 'w') { |file| file.write(read)}