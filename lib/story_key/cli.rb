# frozen_string_literal: true
class StoryKey::CLI < Thor
  package_name 'StoryKey'

  desc 'new [bitsize]',
       "Create a new key/story (default #{::DEFAULT_BITSIZE} bits, max #{::MAX_KEY_SIZE})"
  def new(bitsize = ::DEFAULT_BITSIZE)
    key, story = StoryKey.generate(bitsize:)
    puts [title('Key'), key, title('Story'), story.humanized].join("\n")
  end

  desc 'encode KEY',
       'Encode a key passed as an argument'
  option :format, desc: 'Format of key', enum: %w[base58 hex bin dec], default: :base58
  option :style, desc: 'Style of story', enum: %w[humanized text], default: :humanized
  def encode(key)
    puts encode_key(key, options[:format], options[:style])
  end

  desc 'encodefile SOURCE DESTINATION',
       'Encode a key from SOURCE and write story to DESTINATION'
  option :format, desc: 'Format of key', enum: %w[base58 hex bin dec], default: :base58
  option :style, desc: 'Style of story', enum: %w[humanized text], default: :text
  def encodefile(source, destination)
    raise 'SOURCE and DESTINATION must be different' if source == destination
    story = encode_key(File.read(source), options[:format], options[:style])
    File.write(destination, story.text)
    puts "Story written to #{destination}"
  end

  desc 'decode STORY',
       'Decode a story passed as an argument'
  option :format, desc: 'Format of key', enum: %w[base58 hex bin dec], default: :base58
  def decode(story)
    format ||= options[:format]
    puts StoryKey.decode(story:, format:)
  end

  desc 'decodefile SOURCE DESTINATION',
       'Decode a story from SOURCE and write key to DESTINATION'
  option :format, desc: 'Format of key', enum: %w[base58 hex bin dec], default: :base58
  def decodefile(source, destination)
    raise 'SOURCE and DESTINATION must be different' if source == destination
    key = StoryKey.decode(story: File.read(source), format: options[:format])
    File.write(destination, key)
    puts "Key written to #{destination}"
  end

  desc 'recover', 'Decode a story interactively'
  def recover
    StoryKey.recover
  end

  private

  def encode_key(key, format, style)
    story = StoryKey.encode(key:, format:)
    story.send(style == 'text' ? :text : :humanized)
  end

  def title(str)
    "\e[44m#{str}:\e[0m"
  end
end
