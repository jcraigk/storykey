# frozen_string_literal: true
class StoryKey::Lexicon < StoryKey::Base
  COUNTABLE = 'countable'

  def words
    @words ||= GRAMMAR.values.flatten.uniq.index_with do |part_of_speech|
      txtfile_words(part_of_speech).sort_by do |word|
        [word.text.size, word.text]
      end
    end
  end

  def prepositions
    @prepositions ||= words.values.flatten.filter_map(&:preposition).uniq.sort
  end

  def sha
    @sha ||= Digest::SHA256.hexdigest(words.to_s).first(7)
  end

  private

  def txtfile_words(part_of_speech)
    txtfiles(part_of_speech).map do |path|
      txtfile_lines(path).map do |text|
        Word.new \
          part_of_speech:,
          token: StoryKey::Tokenizer.call(text),
          text: text.gsub(/\[|\]/, ''),
          countable: path.split('/')[-2] == COUNTABLE,
          preposition: text.match(/\[(.+)\]/).to_a[1]
      end
    end.flatten
  end

  def txtfile_lines(path)
    File.readlines(path)
        .map(&:strip)
        .reject { |l| l.start_with?('#') || l.blank? }
  end

  def txtfiles(part_of_speech)
    Dir.glob("lexicons/#{part_of_speech}s/**/*.txt")
  end

  Word = Struct.new \
    :token, :text, :countable, :preposition, :part_of_speech,
    keyword_init: true
end
