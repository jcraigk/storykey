# frozen_string_literal: true
class Peartree::Lexicon < Peartree::Base
  COUNTABLE = 'countable'

  def dictionary
    @dictionary ||= {}.tap do |lex|
      lexicons.each do |part_of_speech, words|
        words.each_with_index do |word, decimal|
          lex[abbrev(word)] = keyword(word, part_of_speech, decimal)
        end
      end
    end
  end

  # Any word after the first is a linking word,
  # included for aesthetics/grammar
  def linking_words
    @linking_words ||= dictionary.filter_map do |_, v|
      v.text.split[1..]
    end.flatten.map(&:downcase).sort.uniq
  end

  def lexicons
    @lexicons ||= LEXICONS.index_with do |part_of_speech|
      txtfile_words(part_of_speech)
    end
  end

  def sha
    Digest::SHA256.hexdigest(dictionary.to_s).first(7)
  end

  private

  def keyword(word, part_of_speech, decimal)
    Keyword.new \
      text: word.text,
      countable: word.countable,
      part_of_speech:,
      decimal:
  end

  def abbrev(word)
    word.text.split[0].downcase[0..(ABBREV_SIZE - 1)]
  end

  def txtfile_words(part_of_speech)
    words = txtfiles(part_of_speech).map do |path|
      txtfile_lines(path).map do |text|
        Word.new(text, path.split('/')[-2] == COUNTABLE)
      end
    end
    words.flatten.sort_by { |w| [w.text.size, w.text] }
  end

  def txtfile_lines(path)
    File.readlines(path)
        .map(&:strip)
        .reject { |l| l.start_with?('#') || l.blank? }
  end

  def txtfiles(part_of_speech)
    Dir.glob("lexicons/#{part_of_speech}s/**/*.txt")
  end

  Keyword = Struct.new \
    :text, :part_of_speech, :decimal, :countable, keyword_init: true
  Word = Struct.new(:text, :countable)
end
