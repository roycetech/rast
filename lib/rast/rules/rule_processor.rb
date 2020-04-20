# frozen_string_literal: true

require 'rast/rules/rule_evaluator'

# undoc
class RuleProcessor
  # /**
  #  * @param scenario current scenario.
  #  * @param caseFixture current test case fixture.
  #  */
  def evaluate(scenario: [], fixture: nil)
    # if scenario.empty? || fixture.nil?
    #   raise 'Scenario or fixture cannot be nil.'
    # end

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
    rule_evaluator = RuleEvaluator.new(converters: spec.converters)

    rule_evaluator.parse(expression: clause)

    list << rule_evaluator.evaluate(
      scenario: scenario,
      rule_token_convert: fixture[:converter_hash]
    )
  end
end
