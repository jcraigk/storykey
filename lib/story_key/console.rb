# frozen_string_literal: true
class StoryKey::Console < Thor
  package_name 'StoryKey'
  map '-i' => :recover

  desc 'new [BITSIZE]',
       <<~TEXT
         Create a new key/story (default #{StoryKey::DEFAULT_BITSIZE} bits, max #{StoryKey::MAX_BITSIZE})
       TEXT
  option :images,
         desc: 'Whether to generate an image (requires OpenAI key and ImageMagick)',
         enum: %w[false true],
         default: 'false',
         aliases: '-i'
  def new(bitsize = StoryKey::DEFAULT_BITSIZE)
    key, story = StoryKey.generate(bitsize: bitsize.to_i)
    puts story_str(key, story)
    print_image_path(story.tokenized, story.phrases) if options[:images] == 'true'
  rescue StoryKey::KeyTooLarge
    quit 'Key too large'
  end

  desc 'encode [KEY]',
       'Encode a key passed as an argument or from a file'
  option :file,
         desc: 'File containing key',
         aliases: '-f'
  option :format,
         desc: 'Format of key',
         enum: %w[base58 hex bin dec],
         default: 'base58'
  option :style,
         desc: 'Style of story',
         enum: %w[humanized text],
         default: 'humanized',
         aliases: '-s'
  option :images,
         desc: 'Whether to generate an image (requires OpenAI key and ImageMagick)',
         enum: %w[false true],
         default: 'false',
         aliases: '-i'
  def encode(key = nil) # rubocop:disable Metrics/AbcSize
    key ||= File.read(options[:file])
    story = StoryKey.encode(key:, format: options[:format])
    puts story.send(options[:style] == 'text' ? :text : :humanized)
    print_image_path(story.phrases) if options[:images] == 'true'
  rescue StoryKey::InvalidFormat
    quit 'Invalid format'
  rescue StoryKey::KeyTooLarge
    quit 'Key too large'
  rescue Errno::ENOENT
    quit 'Invalid file specified'
  end

  desc 'decode [STORY]',
       'Decode a story passed as an argument or from a file'
  option :file,
         desc: 'File containing story',
         aliases: '-f'
  option :format,
         desc: 'Format of key',
         enum: %w[base58 hex bin dec],
         default: 'base58'
  def decode(story = nil)
    story ||= File.read(options[:file])
    format ||= options[:format]
    puts StoryKey.decode(story:, format:)
  rescue StoryKey::InvalidVersion
    puts 'Invalid version'
    exit
  rescue StoryKey::InvalidChecksum, StoryKey::InvalidWord
    puts 'Invalid story'
    exit
  end

  desc 'recover', 'Decode a story interactively'
  def recover
    StoryKey.recover
  end

  private

  def print_image_path(seed, phrases)
    puts 'Generating image...'
    image_path = StoryKey::ImageGenerator.call(seed:, phrases:)
    puts 'No images generated - check your OpenAI key' if image_path.empty?
    puts image_path
  end

  def quit(msg)
    puts msg
    exit
  end

  def titleize(str)
    "\e[44m#{str}:\e[0m"
  end

  def story_str(key, story)
    [
      titleize('Key'),
      key,
      titleize('Story'),
      story.humanized,
      titleize('Seed Phrase'),
      story.tokenized
    ].join("\n")
  end
end
