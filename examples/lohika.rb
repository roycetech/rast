# frozen_string_literal: true

# LogicChecker ported from Java
#
# @author Royce Remulla
#
class Lohika
  # Perform logical AND operation on two arguments.
  #
  # @param argument1 first argument of Boolean type.
  # @param argument2 second argument of Boolean type.
  def at(argument1, argument2)
    return :oo if argument1 == 'oo' && argument2 == 'oo'

    :hindi
  end

  # Perform logical OR operation on two arguments.
  #
  # @param argument1 first argument of Boolean type.
  # @param argument2 second argument of Boolean type.
  def o(argument1, argument2)
    return :oo if argument1 == 'oo' || argument2 == 'oo'

    :hindi
  end
end
