# frozen_string_literal: true

# Provides logic evaluation functionalities.
module LogicHelper
  # /**
  #  * Custom logical AND/OR evaluator.
  #  *
  #  * @author Royce
  #  */

  TRUE = '*true'
  FALSE = '*false'

  OPPOSITE = {
    TRUE => FALSE,
    FALSE => TRUE
  }.freeze

  LOGIC_PRIMARY_RESULT = {
    and: FALSE,
    or: TRUE
  }.freeze

  # /**
  #  * @scenario list of scenario tokens.
  #  * @left left left token object.
  #  * @right right right token object.
  #  * @operation :and or :or.
  #  * @returns String boolean value, can be internal, thus it is string.
  #  */
  def perform_logical(scenario: [], left: {}, right: {}, operation: :nil)
    evaluated = both_internal?(left, right, operation)
    return evaluated if evaluated

    default = operation == :and ? TRUE : FALSE
    return present?(scenario, right).to_s if internal_match?(default, left)

    return present?(scenario, left).to_s if internal_match?(default, right)

    send("evaluate_#{operation}", scenario, left, right).to_s
  end

  # /**
  #  * Check if the token is opening bracket.
  #  *
  #  * @token Input <code>String</code> token
  #  * @return <code>boolean</code> output
  #  */
  def open_bracket?(token: '')
    token == '('
  end

  # /**
  #  * Check if the token is closing bracket.
  #  *
  #  * @param token Input <code>String</code> token
  #  * @return <code>boolean</code> output
  #  */
  def close_bracket?(token: '')
    token == ')'
  end

  private

  # @left hash containing token and subscript
  # @right hash containing token and subscript
  # @operation symbol either :and or :or
  def both_internal?(left, right, operation)
    default = LOGIC_PRIMARY_RESULT[operation]
    if internal_match?(default, left) || internal_match?(default, right)
      return default
    end

    opposite = OPPOSITE[default]
    if internal_match?(opposite, left) && internal_match?(opposite, right)
      return opposite
    end

    false
  end

  def evaluate_and(scenario, left, right)
    left_eval = present?(scenario, left)

    return false unless left_eval

    present?(scenario, right)
  end

  def evaluate_or(scenario, left, right)
    left_eval = present?(scenario, left)

    return true if left_eval

    present?(scenario, right)
  end

  # /**
  #  * Helper method to evaluate left or right token.
  #  *
  #  * @param scenario list of scenario tokens.
  #  * @param subscript scenario token subscript.
  #  * @param object left or right token.
  #  */
  def present?(scenario, token)
    if token[:subscript] < 0
      scenario.include?(token[:value])
    else
      scenario[token[:subscript]] == token[:value]
    end
  end

  def internal_match?(internal, token)
    token[:value] == internal && token[:subscript] == -1
  end
end
