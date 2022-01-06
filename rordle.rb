#!/usr/bin/env ruby
require "readline"
require "rainbow/refinement"

using Rainbow

def relative_file(file_name)
  File.expand_path(file_name, __dir__)
end

def word_allowed?(word)
  # A binary string search inside the allow5 file would be the most complicated
  # thing in this program.
  File.readlines(relative_file("allow5.txt"), chomp: true).include?(word.downcase)
end

def choose_random_word
  File.foreach(relative_file("target5.txt")).map(&:chomp).sample.upcase
end

def background_color(word:, letter:, guess_letter:)
  return :green if letter == guess_letter
  return :yellow if word.include?(guess_letter)

  :lightgray
end

def print_line(word:, guess:)
  cells = word.each_char.zip(guess.each_char).map do |letter, guess_letter|
    color = background_color(word: word, letter: letter, guess_letter: guess_letter)
    " #{guess_letter.upcase} ".black.background(color)
  end

  puts cells.join(" ")
end

def print_board(word:, history:)
  puts
  history.each do |entry|
    print_line(word: word, guess: entry)
  end
  puts
end

def print_empty_board
  print_board(word: "?????", history: ["     "])
end

word = choose_random_word
history = []

loop do
  if history.empty?
    print_empty_board
  else
    print_board(word: word, history: history)

    if word == history.last
      puts "You won in #{history.size.to_s.bright} attempts. The word was #{word.green}."
      break
    end
  end

  begin
    guess = Readline.readline("Guess: ", true)

    if guess.nil?
      puts "(it was #{word.yellow})"
      break
    end

    guess = guess.strip.upcase
  rescue Interrupt
    break
  end

  if guess.chars.size != word.chars.size
    puts "Word must be 5 characters".red
    next
  end

  unless word_allowed?(guess)
    puts "Word not in list".red
    next
  end

  history.push(guess)
end
