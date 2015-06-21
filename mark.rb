require 'marky_markov'

class MGSMarkov
  def initialize
    @markov = MarkyMarkov::TemporaryDictionary.new
    @markov.parse_file "output2.txt"
  end

  def make_sentence
    arr = []
    7.times do
      arr.push(@markov.generate_n_sentences(1))
    end
    until arr.join(' ').length < 100
      arr.shift
    end
    arr
  end
end
