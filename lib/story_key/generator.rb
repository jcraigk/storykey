# frozen_string_literal: true
class StoryKey::Generator < StoryKey::Base
  option :bitsize

  def call
    random_binary_str
  end

  private

  def random_binary_str
    SecureRandom.random_bytes(32)
                .unpack1('H*')
                .hex
                .to_s(2)
                .first(bitsize)
                .rjust(bitsize, '0')
  end
end
