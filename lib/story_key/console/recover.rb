# frozen_string_literal: true
class StoryKey::Recover < StoryKey::Base
  include Remedy

  BG_BLUE = 44
  BG_GREEN = 42
  BG_MAGENTA = 45
  BG_RED = 41
  EXIT_WORD = :control_x
  FRAME_HORIZONTAL = '='
  GREEN = 32
  NUM_OPTIONS = 5
  RED = 31

  def call
    @word_idx = 0
    @option_idx = 0
    clear_options
    clear_user_str
    @prompt = 'Enter word: '

    ask_version_slug
    ask_num_phrases
    ask_num_tail_words
    interactive_phrase_recovery
  end

  attr_accessor :num_phrases, :num_tail_words, :instructions, :prompt,
                :user_str, :options, :option_idx, :word_idx

  private

  def listen # rubocop:disable Metrics/MethodLength
    console.loop do |key|
      key = key.to_s.to_sym
      case key_sym
      when EXIT_WORD then quit_console
      when :up, :down then move_option_cursor(key)
      when :left, :right, :tab then move_word_cursor(key)
      when :backspace, :delete then input_backspace
      when :carriage_return, :control_m then input_enter
      else input_misc_key(key)
      end

      draw
    end
  end

  def input_misc_key(key)
    return unless key.match?(/([a-zA-Z0-9\s]|dash)/)
    @user_str += key.to_s
    refresh_options
  end

  def input_enter
    return if (word = options[option_idx]).blank?
    words[word_idx] = word
    return decode_and_hault if board_complete?
    move_word_cursor(:right)
  end

  def clear_user_str
    @user_str = ''
  end

  def input_backspace
    @user_str = @user_str[0..-2]
    refresh_options
  end

  def clear_options
    @options = []
    @option_idx = 0
  end

  def decode_and_hault
    clear_user_str
    clear_options
    @word_idx = -1
    @instructions = decode_story
    @prompt = colorize('(press any key to exit)', RED)
    draw
    console.get_key
    quit_console
  end

  def decode_story
    key = StoryKey.decode(story: "#{StoryKey::VERSION_SLUG} #{words.join(' ')}")
    "#{colorize('Key:', BG_BLUE)} #{colorize(key, GREEN)}"
  rescue StoryKey::InvalidChecksum
    colorize('Checksum failed! Invalid story.', BG_RED)
  end

  def refresh_options # rubocop:disable Metrics/AbcSize
    chars = user_str.chars
    all_words = lex.words[parts_of_speech[word_idx].to_sym].map(&:text)
    substr_matches = user_str.size > 2 ? all_words.grep(/.*#{user_str}.*/i) : []
    fuzzy_matches = all_words.grep(/.*#{chars.join('.*')}.*/i)
    @options = (substr_matches + fuzzy_matches).uniq.take(NUM_OPTIONS)
    @option_idx = 0
  end

  def interactive_phrase_recovery
    init_viewport
    listen
  end

  def ask_version_slug
    print "Did your story take place in #{StoryKey::VERSION_SLUG}? (y) "
    key = console.get_key
    puts
    return if confirm?(key)
    quit('Sorry, this version of StoryKey can\'t decode your story')
  end

  def num_parts
    GRAMMAR.keys.max
  end

  def default_num_phrases
    ((DEFAULT_BITSIZE / BITS_PER_WORD.to_f) / num_parts).ceil
  end

  def max_num_phrases
    ((MAX_KEY_SIZE / BITS_PER_WORD.to_f) / num_parts).ceil
  end

  def ask_num_phrases
    print "How many phrases are in your story? (#{default_num_phrases}) "
    ARGV.clear
    input = gets
    input = default_num_phrases if input.blank?
    @num_phrases = input.to_i.tap do |i|
      quit('Invalid number') unless i.in?(1..max_num_phrases)
    end
  end

  def ask_num_tail_words
    default = 3
    print "How many words in last phrase? (#{default}) "
    input = gets
    input = default if input.blank?
    @num_tail_words = input.to_i.tap do |i|
      quit('Invalid number') unless i.in?(1..max_parts_in_phrase)
    end
  end

  def max_parts_in_phrase
    GRAMMAR.keys.max
  end

  def words
    return @words if @words
    ary = []
    num_phrases.times do |idx|
      grammar_idx = idx + 1 == num_phrases ? num_tail_words : max_parts_in_phrase
      grammar = GRAMMAR[grammar_idx]
      ary += grammar.map { |part_of_speech| "[#{part_of_speech}]" }
    end
    @words = ary
  end

  # TODO: Grammarize
  def board_rows
    ["In #{StoryKey::VERSION_SLUG} I saw"].tap do |ary|
      idx = 0
      words.each_slice(GRAMMAR.keys.max).to_a.each_with_index.map do |word_group, row|
        parts = []
        last_row = row == num_phrases - 1
        if num_phrases > 1
          parts << "#{row + 1}."
          parts << (last_row ? 'and a' : 'an')
        end
        word_group.each do |word|
          parts << (word_idx == idx ? colorize(word, BG_MAGENTA) : word)
          idx += 1
        end

        str = parts.join(' ')
        str += (last_row ? '.' : ',')
        ary << str
      end
    end
  end

  def option_rows
    options.each_with_index.map do |opt, idx|
      "#{' ' * prompt.size}#{idx == option_idx ? colorize(opt, BG_GREEN) : opt}"
    end
  end

  def move_word_cursor(key)
    @word_idx = word_idx.send((key == :left ? '-' : '+'), 1) % words.size
    clear_user_str
    clear_options
  end

  def move_option_cursor(key)
    @option_idx =
      if options.any?
        option_idx.send((key == :up ? '-' : '+'), 1) % options.size
      else
        0
      end
  end

  def board_complete?
    words.grep(/\[.+\]/).empty?
  end

  def num_words
    (num_phrases - 1)
  end

  def init_viewport
    @instructions = colorize \
      "\u2190 \u2192  Story   \u2191 \u2193 Suggestions   Ctr-X", BG_BLUE
    ANSI.screen.safe_reset!
    ANSI.cursor.home!
    ANSI.command.clear_screen!
    draw
  end

  def console
    @console ||= Interaction.new
  end

  def colorize(text, num)
    return text if text.blank? || num.blank?
    "\e[#{num}m#{text}\e[0m"
  end

  def draw
    viewport.draw(user_prompt, Size([0, 0]), board_view, options_view)
  end

  def user_prompt
    hr = FRAME_HORIZONTAL * 36
    Partial.new([hr, instructions, hr, "#{prompt}#{user_str}"])
  end

  def board_view
    Partial.new(board_rows)
  end

  def options_view
    Partial.new(option_rows)
  end

  def viewport
    @viewport ||= Viewport.new
  end

  def quit_console
    ANSI.cursor.home!
    ANSI.command.clear_down!
    ANSI.cursor.show!
    exit
  end

  def quit(msg)
    puts msg
    exit
  end

  def confirm?(key)
    key.to_s.in?(%w[Y y carriage_return control_m])
  end

  def parts_of_speech
    @parts_of_speech ||= words.map { |w| w.tr('[]', '') }
  end

  def lex
    @lex ||= StoryKey::Lexicon.new
  end
end
