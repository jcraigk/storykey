# frozen_string_literal: true
class Peartree::Lexicon < Peartree::Base
  COUNTABLE = 'countable'

  def words
    @words ||= LEXICONS.index_with do |part_of_speech|
      txtfile_words(part_of_speech)
    end
  end

  def base_words
    @base_words ||=
      words.transform_values do |words|
        words.map do |word|
          word.text.split[0].downcase[0..(ABBREV_SIZE - 1)]
        end
      end
  end

  # Any word after the first is a linking word,
  # included for aesthetics/grammar
  # TODO: use markup instead to accommodate more forms
  def linking_words
    @linking_words ||= words.transform_values do |words|
      words.map { |word| word.text.split[1..] }
    end.values.flatten.compact.uniq.sort
  end

  def sha
    Digest::SHA256.hexdigest(words.to_s).first(7)
  end

  private

  def keyword(word, part_of_speech, decimal)
    Keyword.new \
      text: word.text,
      countable: word.countable,
      part_of_speech:,
      decimal:
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
