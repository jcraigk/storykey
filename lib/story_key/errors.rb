# frozen_string_literal: true
module StoryKey
  class Error < StandardError; end
  class InvalidFormat < Error; end
  class InvalidVersion < Error; end
  class InvalidWord < Error; end
  class InvalidChecksum < Error; end
  class KeyTooLarge < Error; end
end
