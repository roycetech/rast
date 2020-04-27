# frozen_string_literal: true

# Checks bug introduced when converters was combined with token converter.
#
# @author Royce Remulla
#
class LogicFour
  # Perform logical AND operation on two arguments.
  #
  # @param argument1 first argument of Boolean type.
  # @param argument2 second argument of Boolean type.
  def process(argument1, argument2, argument3, argument4)
    !argument1 && !argument2 && !argument3 && argument4 == 'a'
  end
end
