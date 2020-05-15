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

  # /**
  #  * @param scenario list of scenario tokens.
  #  * @param left_subscript left index.
  #  * @param right_subscript right index.
  #  * @param left left token, no subscript.
  #  * @param right right token, no subscript.
  #  */
  def perform_logical_and(
    scenario: [],
    left_subscript: -1,
    right_subscript: -1,
    left: nil,
    right: nil
  )

    evaluated = both_internal_and?(left, left_subscript, right, right_subscript)
    return evaluated if evaluated

    if internal_match?(TRUE, left, left_subscript)
      return present?(scenario, right, right_subscript).to_s
    end

    if internal_match?(TRUE, right, right_subscript)
      return present?(scenario, left, left_subscript).to_s
    end

    evaluate_and(scenario, left, left_subscript, right, right_subscript).to_s
  end

  # /**
  #  * @param scenario list of scenario tokens.
  #  * @param left_subscript left index.
  #  * @param right_subscript right index.
  #  * @param left left token.
  #  * @param right right token.
  #  */
  def perform_logical_or(scenario: [], left_subscript: -1, right_subscript: -1,
                         left: nil, right: nil)
    evaluated = both_internal_or?(left, left_subscript, right, right_subscript)
    return evaluated if evaluated

    if internal_match?(FALSE, left, left_subscript)
      return present?(scenario, right, right_subscript).to_s
    end

    if internal_match?(FALSE, right, right_subscript)
      return present?(scenario, left, left_subscript).to_s
    end

    evaluate_or(scenario, left, left_subscript, right, right_subscript).to_s
  end

  # /**
  #  * Check if the token is opening bracket.
  #  *
  #  * @param token Input <code>String</code> token
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

  def both_internal_and?(left, left_subscript, right, right_subscript)
    if internal_match?(FALSE, left, left_subscript) ||
       internal_match?(FALSE, right, right_subscript)

      return FALSE
    end

    if internal_match?(TRUE, left, left_subscript) &&
       internal_match?(TRUE, right, right_subscript)

      TRUE
    end
  end

  def both_internal_or?(left, left_subscript, right, right_subscript)
    if internal_match?(TRUE, left, left_subscript) ||
       internal_match?(TRUE, right, right_subscript)

      return TRUE
    end

    if internal_match?(FALSE, left, left_subscript) &&
       internal_match?(FALSE, right, right_subscript)

      FALSE
    end
  end

  def evaluate_and(scenario, left, left_subscript, right, right_subscript)
    left_eval = present?(scenario, left, left_subscript)

    return false unless left_eval

    right_eval = present?(scenario, right, right_subscript)
    left_eval && right_eval
  end

  def evaluate_or(scenario, left, left_subscript, right, right_subscript)
    left_eval = present?(scenario, left, left_subscript)

    return true if left_eval

    right_eval = present?(scenario, right, right_subscript)
    left_eval || right_eval
  end

  # /**
  #  * Helper method to evaluate left or right token.
  #  *
  #  * @param scenario list of scenario tokens.
  #  * @param subscript scenario token subscript.
  #  * @param object left or right token.
  #  */
  def present?(scenario, value, subscript)
    if subscript < 0
      scenario.include?(value)
    else
      scenario[subscript] == value
    end
  end

  def internal_match?(internal, value, subscript)
    value == internal && subscript == -1
  end
end
