# frozen_string_literal: true
class Peartree::Coercer < Peartree::Base
  param :str
  param :input, default: -> { :hex }
  param :output, default: -> { :base58 }

  def call
    converted_str
  end

  private

  def binary_str
    @binary_str ||=
      case input.to_sym
      when :bin, :binary then str
      when :dec, :decimal then str.to_i.to_s(2)
      when :hex, :hexidecimal then str.hex.to_s(2)
      when :base58 then Base58.base58_to_int(str, :bitcoin).to_s(2)
      else raise Peartree::InvalidFormat, "Invalid input format: #{input}"
      end
  end

  def converted_str
    case output.to_sym
    when :bin, :binary then binary_str
    when :dec, :decimal then decimal_str
    when :hex, :hexidecimal then hexidecimal_str
    when :base58 then base58_str
    else raise Peartree::InvalidFormat, "Invalid output format: #{output}"
    end
  end

  def decimal_str
    binary_str.reverse.chars.map.with_index do |digit, index|
      digit.to_i * (2**index)
    end.sum.to_s
  end

  def hexidecimal_str
    binary_str.to_i(2).to_s(16)
  end

  def base58_str
    Base58.int_to_base58(decimal_str.to_i, :bitcoin)
  end
end
