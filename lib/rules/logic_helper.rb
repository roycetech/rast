
# Provides logic evaluation functionalities.
module LogicHelper
  # /**
  #  * Custom logical AND/OR evaluator.
  #  *
  #  * @author Royce
  #  */

  TRUE = '|true'
  FALSE = '|false'

  # /**
  #  * @param scenario list of scenario tokens.
  #  * @param left_subscript left index.
  #  * @param right_subscript right index.
  #  * @param left left token.
  #  * @param right right token.
  #  */
  def perform_logical_and(scenario: [], left_subscript: -1, right_subscript: -1,
                          left: nil, right: nil)
    if FALSE == left || FALSE == right
      FALSE
    elsif TRUE == left && TRUE == right
      TRUE
    elsif TRUE == left
      if right_subscript.negative?
        scenario.include?(right).to_s
      else
        (scenario[right_subscript] == right).to_s
      end
    elsif TRUE == right
      if left_subscript.negative?
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
    if TRUE == left || TRUE == right
      TRUE
    elsif FALSE == left && FALSE == right
      FALSE
    elsif FALSE == left
      if right_subscript.negative?
        scenario.include?(right).to_s
      else
        (scenario[right_subscript] == right).to_s
      end
    elsif FALSE == right
      if left_subscript.negative?
        scenario.include?(left).to_s
      else
        (scenario[left_subscript]).to_s == left
      end
    else
      left_eval = pevaluate(
        scenario: scenario,
        subscript: left_subscript,
        object: left
      )

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
    if subscript.negative?
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
