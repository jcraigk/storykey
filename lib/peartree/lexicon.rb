# frozen_string_literal: true
class Peartree::Lexicon < Peartree::Base
  COUNTABLE = 'countable'

  def words
    @words ||= processed_words.transform_values do |words|
      words.sort_by { |word| [word.text.size, word.text] }
    end
  end

  # Any word after the first is a linking word,
  # included for aesthetics/grammar
  def linking_words
    @linking_words ||=
      raw_words.values.flatten.filter_map do |word|
        word.text.match(/\[(.+)\]/).to_a[1]
      end.uniq.sort
  end

  def sha
    Digest::SHA256.hexdigest(words.to_s).first(7)
  end

  private

  def processed_words
    raw_words.transform_values do |words|
      words.map do |word|
        Word.new \
          word.text.gsub(/[\[\]]/, ''),
          word.countable,
          Peartree::Tokenizer.call(word.text)
      end
    end
  end

  def raw_words
    LEXICONS.index_with do |part_of_speech|
      txtfile_words(part_of_speech)
    end
  end

  def txtfile_words(part_of_speech)
    words = txtfiles(part_of_speech).map do |path|
      txtfile_lines(path).map do |text|
        Word.new(text, path.split('/')[-2] == COUNTABLE)
      end
    end
    words.flatten
  end

  def txtfile_lines(path)
    File.readlines(path)
        .map(&:strip)
        .reject { |l| l.start_with?('#') || l.blank? }
  end

  def txtfiles(part_of_speech)
    Dir.glob("lexicons/#{part_of_speech}s/**/*.txt")
  end

  Word = Struct.new(:text, :countable, :token)
end
