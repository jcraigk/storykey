class StoryKey::Base
  extend Dry::Initializer
  extend ::ActiveSupport::Concern

  def self.call(...)
    new(...).call
  end
end
