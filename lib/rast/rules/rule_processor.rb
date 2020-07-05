# frozen_string_literal: true

require 'rast/rules/rule_evaluator'

# undoc
class RuleProcessor
  def initialize(rule: nil, token_converters: {})
    @rule = rule
    @token_converters = token_converters
  end

  # /**
  #  * @param scenario current scenario.
  #  *
  #  * @return the outcome results against the given scenario.
  #  */
  def evaluate(scenario: [])
    @rule.outcomes.inject([]) do |retval, outcome|
      process_outcome(
        list: retval,
        scenario: scenario,
        outcome: outcome
      )
    end
  end

  private

  # @returns the list argument with the new result.
  def process_outcome(list: [], scenario: [], outcome: '')
    clause = @rule.clause(outcome: outcome)
    rule_evaluator = RuleEvaluator.new(token_converters: @token_converters)
    rule_evaluator.parse(expression: clause)

    list << rule_evaluator.evaluate(scenario: scenario)
  end
end
