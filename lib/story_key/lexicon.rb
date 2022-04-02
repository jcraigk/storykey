# frozen_string_literal: true
class StoryKey::Lexicon < StoryKey::Base
  COUNTABLE = 'countable'

  def entries
    @entries ||= GRAMMAR.values.flatten.uniq.index_with do |part_of_speech|
      txtfile_entries(part_of_speech).sort_by(&:token)
    end
  end

  def prepositions
    @prepositions ||= entries.values.flatten.filter_map(&:preposition).uniq.sort
  end

  def sha
    @sha ||= Digest::SHA256.hexdigest(entries.to_s).first(7)
  end

  private

  def txtfile_entries(part_of_speech)
    txtfiles(part_of_speech).map do |path|
      txtfile_lines(path).map do |text|
        new_entry(text, part_of_speech, path)
      end
    end.flatten
  end

  def new_entry(text, part_of_speech, path)
    StoryKey::Entry.new \
      raw: text,
      text: text.gsub(/\[|\]/, ''),
      part_of_speech:,
      token: StoryKey::Tokenizer.call(text),
      countable: path.split('/')[-2] == COUNTABLE,
      preposition: text.match(/\[(.+)\]/).to_a[1]
  end

  def txtfile_lines(path)
    File.readlines(path)
        .map(&:strip)
        .reject { |l| l.start_with?('#') || l.blank? }
  end

  def txtfiles(part_of_speech)
    Dir.glob("lexicons/#{part_of_speech}s/**/*.txt")
  end
end
