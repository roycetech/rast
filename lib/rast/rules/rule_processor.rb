# frozen_string_literal: true

require 'rast/rules/rule_evaluator'

# undoc
class RuleProcessor
  # /**
  #  * @param scenario current scenario.
  #  * @param caseFixture current test case fixture.
  #  */
  def evaluate(scenario: [], fixture: nil)
    fixture[:spec].rule.outcomes.inject([]) do |retval, outcome|
      process_outcome(
        scenario: scenario,
        fixture: fixture,
        list: retval,
        outcome: outcome
      )
    end
  end

  private

  def process_outcome(scenario: [], fixture: nil, list: [], outcome: '')
    spec = fixture[:spec]

    clause = spec.rule.clause(outcome: outcome)
    rule_evaluator = RuleEvaluator.new(token_converters: spec.token_converter)

    rule_evaluator.parse(expression: clause)

    list << rule_evaluator.evaluate(
      scenario: scenario,
      rule_token_convert: spec.token_converter
    )
  end
end
