class StoryKey::Lexicon < StoryKey::Base
  def entries
    @entries ||= StoryKey::GRAMMAR.values.flatten.uniq.index_with do |part_of_speech|
      import_entries(part_of_speech).sort_by(&:token)
    end
  end

  def prepositions
    @prepositions ||= entries.values.flatten.filter_map(&:preposition).uniq.sort
  end

  def sha
    @sha ||= Digest::SHA256.hexdigest(entries.to_s).first(StoryKey::LEXICON_SHA_SIZE)
  end

  private

  def import_entries(part_of_speech)
    [].tap do |ary|
      StoryKey::Data::ENTRIES[part_of_speech].each do |group, entries|
        entries.each do |text|
          ary << new_entry(part_of_speech, text, group == :countable)
        end
      end
    end
  end

  def new_entry(part_of_speech, text, countable)
    StoryKey::Entry.new \
      part_of_speech:,
      raw: text,
      text: text.gsub(/\[|\]/, ""),
      token: StoryKey::Tokenizer.call(text),
      countable:,
      preposition: text.match(/\[(.+)\]/).to_a[1]
  end
end
