# frozen_string_literal: true
class Mnemonica::Decoder
  extend Dry::Initializer

  param :str

  def call
    hex
  end

  private

end
