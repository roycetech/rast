# frozen_string_literal: true

# Operator Enum in Java. To be used only internally in RuleEvaluator class.
class Operator
  # Not('!', Byte.MAX_VALUE), And('&', (byte) 2), Or('|', (byte) 1)

  attr_reader :name, :symbol, :precedence

  def initialize(name: '', symbol: '', precedence: -1)
    @name = name
    @symbol = symbol
    @precedence = precedence
  end

  def to_s
    @operator.to_s
  end
end
