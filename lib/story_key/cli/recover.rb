# frozen_string_literal: true
class StoryKey::Recover < StoryKey::Base
  include Remedy

  attr_accessor :num_phrases, :num_tail_words, :user_str,
                :options, :option_idx, :word_idx, :instructions, :prompt

  # FRAME_VERTICAL = "\u02551"
  FRAME_HORIZONTAL = '='
  BG_MAGENTA = 45
  BG_GREEN = 42
  GREEN = 32
  BG_BLUE = 44
  RED = 31;
  BG_RED = 41
  NUM_OPTIONS = 5

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

  private

  def listen
    console.loop do |key|
      quit_console! if quit_key?(key)

      key_sym = key.to_s.to_sym

      case key_sym
      when :up, :down
        move_option_cursor(key_sym)
      when :left, :right, :tab
        move_word_cursor(key_sym)
        clear_user_str
      when :backspace, :delete
        @user_str = @user_str[0..-2]
        refresh_options
      when :carriage_return, :control_m
        if (word = options[option_idx]).present?
          words[word_idx] = word
          return decode! if board_complete?
          move_word_cursor(:right)
          clear_user_str
          clear_options
        end
      when :control_c, :control_d
        quit_console!
      else
        if key_sym.match?(/([a-zA-Z0-9\s]|dash)/)
          @user_str += key.to_s
          refresh_options
        end
      end

      draw
    end
  end

  def clear_user_str
    @user_str = ''
  end

  def clear_options
    @options = []
    @option_idx = 0
  end

  def decode!
    clear_user_str
    clear_options
    begin
      key = StoryKey.decode(story: "#{StoryKey::VERSION_SLUG} #{words.join(' ')}")
      @instructions = "#{colorize('Key:', BG_BLUE)} #{colorize(key, GREEN)}"
    rescue StoryKey::InvalidChecksum
      @instructions = colorize('Checksum failed! Invalid story.', BG_RED)
    end

    @prompt = colorize('(press any key to exit)', RED)
    @word_idx = -1
    draw
    console.get_key
    quit_console!
  end

  # TODO: Use third party fuzzy matching solution?
  def refresh_options
    chars = user_str.chars
    all_words = lex.words[parts_of_speech[word_idx].to_sym].map(&:text)
    substr_matches = user_str.size > 2 ? all_words.grep(/.*#{user_str}.*/i) : []
    fuzzy_matches = all_words.grep(/.*#{chars.join('.*')}.*/i)
    @options = (substr_matches + fuzzy_matches).uniq.take(NUM_OPTIONS)
    # @options.map { |opt| opt.gsub(/(#{chars.join('|')})/) { |m| colorize(m, BG_GREEN) } }
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

  def ask_num_phrases
    num_parts = GRAMMAR.first[1].count
    default = ((DEFAULT_BITSIZE / BITS_PER_WORD.to_f) / num_parts).ceil
    max = ((MAX_KEY_SIZE / BITS_PER_WORD.to_f) / num_parts).ceil
    print "How many phrases are in your story? (#{default}) "
    ARGV.clear
    input = gets
    input = default if input.blank?
    @num_phrases = input.to_i.tap do |i|
      quit('Invalid number') unless i.in?(1..max)
    end
  end

  def ask_num_tail_words
    default = 3 # TODO: derive this
    print "How many words in last phrase? (#{default}) "
    input = gets
    input = default if input.blank?
    @num_tail_words = input.to_i.tap do |i|
      quit('Invalid number') unless i.in?(1..max_parts_in_phrase)
    end
  end

  def max_parts_in_phrase
    GRAMMAR.first[1].count
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

  # TODO: Make the grammar fancy as each word is updated
  # Extract from Encoder
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
    @instructions = colorize("\u2190 \u2192  Navigate story | \u2191 \u2193  Autocomplete", 44)

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
    hr = FRAME_HORIZONTAL * 40
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

  def quit_console!
    ANSI.cursor.home!
    ANSI.command.clear_down!
    ANSI.cursor.show!
    exit
  end

  def quit_key?(key)
    key.to_s.in?(%i[control_c control_d])
  end

  def quit(msg)
    puts msg
    exit
  end

  def confirm?(key)
    key.to_s.in?(%w[Y y carriage_return control_m])
  end

  def parts_of_speech
    @part_of_speech ||= words.map { |w| w.tr('[]', '') }
  end

  def lex
    @lex ||= StoryKey::Lexicon.new
  end
end
