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
  def perform_logical_and(scenario: [], left_subscript: -1, right_subscript: -1,
                          left: nil, right: nil)
    if FALSE == left && left_subscript == -1 || FALSE == right && right_subscript == -1
      FALSE
    elsif TRUE == left && left_subscript == -1 && TRUE == right && right_subscript == -1
      TRUE
    elsif TRUE == left && left_subscript == -1
      if right_subscript < 0
        scenario.include?(right).to_s
      else
        (scenario[right_subscript] == right).to_s
      end
    elsif TRUE == right && right_subscript == -1
      if left_subscript < 0
        scenario.include?(left).to_s
      else
        (scenario[left_subscript] == left).to_s
      end
    else
      left_eval = pevaluate(
        scenario: scenario,
        subscript: left_subscript,
        object: left
      )

      return 'false' unless left_eval

      right_eval = pevaluate(
        scenario: scenario,
        subscript: right_subscript,
        object: right
      )

      (left_eval && right_eval).to_s
    end
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
    if TRUE == left && left_subscript == -1 || TRUE == right && right_subscript == -1
      TRUE
    elsif FALSE == left && left_subscript == -1 && FALSE == right && right_subscript == -1
      FALSE
    elsif FALSE == left && left_subscript == -1
      if right_subscript < 0
        scenario.include?(right).to_s
      else
        (scenario[right_subscript] == right).to_s
      end
    elsif FALSE == right && right_subscript == -1
      if left_subscript < 0
        scenario.include?(left).to_s
      else
        (scenario[left_subscript] == left).to_s
      end
    else
      left_eval = pevaluate(
        scenario: scenario,
        subscript: left_subscript,
        object: left
      )

      return 'true' if left_eval

      right_eval = pevaluate(
        scenario: scenario,
        subscript: right_subscript,
        object: right
      )

      (left_eval || right_eval).to_s
    end
  end

  # /**
  #  * Helper method to evaluate left or right token.
  #  *
  #  * @param scenario list of scenario tokens.
  #  * @param subscript scenario token subscript.
  #  * @param object left or right token.
  #  */
  def pevaluate(scenario: [], subscript: -1, object: nil)
    if subscript < 0
      scenario.include?(object)
    else
      scenario[subscript] == object
    end
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
end
