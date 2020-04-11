# frozen_string_literal: true

# LogicChecker ported from Java
#
# @author Royce Remulla
#
class LogicChecker
  # Perform logical AND operation on two arguments.
  #
  # @param argument1 first argument of Boolean type.
  # @param argument2 second argument of Boolean type.
  def and(argument1, argument2)
    argument1 && argument2
  end

  # Perform logical OR operation on two arguments.
  #
  # @param argument1 first argument of Boolean type.
  # @param argument2 second argument of Boolean type.
  def or(argument1, argument2)
    argument1 || argument2
  end
end
