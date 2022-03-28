# frozen_string_literal: true
class StoryKey::Recover < StoryKey::Base
  include Remedy

  attr_accessor :num_phrases, :num_tail_words, :user_str,
                :options, :option_idx, :word_idx

  # FRAME_VERTICAL = "\u02551"
  FRAME_HORIZONTAL = '='
  BG_MAGENTA = 45
  BG_GREEN = 42
  PROMPT = 'Enter word: '
  NUM_OPTIONS = 5

  def call
    @word_idx = 0
    @option_idx = 0
    @options = []
    @user_str = ''

    prompt_version
    prompt_num_phrases
    prompt_num_tail_words
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
        @user_str = ''
      when :backspace, :delete
        @user_str = @user_str[0..-2]
        update_options
      when :carriage_return, :control_m
        if (word = options[option_idx]).present?
          words[word_idx] = word
          decode! if board_complete?
          move_word_cursor(:right)
          @user_str = ''
          @options = []
        end
      when :control_c, :control_d
        quit_console!
      else
        if key_sym.match?(/([a-zA-Z0-9\s]|dash)/)
          @user_str += key.to_s
          update_options
        end
      end

      draw
    end
  end

  def decode!
    puts "Decoding!"
    quit_console!
  end

  def update_options
    @options =
      lex.words[parts_of_speech[word_idx].to_sym]
         .map(&:text)
         .grep(/.*#{user_str.chars.join('.*')}.*/i)
         .take(NUM_OPTIONS)
    @option_idx = 0
  end

  def interactive_phrase_recovery
    init_viewport
    listen
  end

  def prompt_version
    print "Did your story take place in #{StoryKey::VERSION_SLUG}? (y) "
    key = console.get_key
    puts
    return if confirm?(key)
    quit('Sorry, this version of StoryKey can\'t decode your story')
  end

  def prompt_num_phrases
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

  def prompt_num_tail_words
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

  def menu_rows
    options.each_with_index.map do |opt, idx|
      str = "#{' ' * PROMPT.size}#{opt}"
      idx == option_idx ? colorize(str, BG_MAGENTA) : str
    end
  end

  def user_prompt_str
    "#{PROMPT}#{user_str}"
  end

  def instructions
    colorize("\u2190 \u2192  Navigate story | \u2191 \u2193  Autocomplete", 44)
  end

  def move_word_cursor(key)
    @word_idx = word_idx.send((key == :left ? '-' : '+'), 1) % words.size
  end

  def move_option_cursor(key)
    @option_idx = option_idx.send((key == :left ? '-' : '+'), 1) % options.size
  end

  def board_complete?
    words.grep(/\[.+\]/).empty?
  end

  def num_words
    (num_phrases - 1)
  end

  def init_viewport
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
    viewport.draw(user_prompt, Size([0, 0]), board_view, menu_view)
  end

  def user_prompt
    hr = FRAME_HORIZONTAL * 40
    Partial.new([hr, instructions, hr, user_prompt_str])
  end

  def board_view
    Partial.new(board_rows)
  end

  def menu_view
    Partial.new(menu_rows)
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
