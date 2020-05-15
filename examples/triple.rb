# frozen_string_literal: true

# Triple. This example is used to test automatic detection of variable data type in yaml.
#
# @author Royce Remulla
#
class Triple
  # Perform logical AND operation on two arguments.
  #
  # @param argument1 first argument of Boolean type.
  # @param argument2 second argument of Boolean type.
  def triple(argument1, argument2, _argument3)
    argument1 && argument2
  end
end
