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