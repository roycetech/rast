# frozen_string_literal: true

# Example single number answer
class Positive2
  def positive?(number)
    raise 'Invalid' unless number.is_a? Numeric

    number > 0
  end
end
