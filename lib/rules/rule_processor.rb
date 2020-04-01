# frozen_string_literal: true

require './lib/rules/rule_evaluator'

# undoc
class RuleProcessor
  # /**
  #  * @param scenario current scenario.
  #  * @param caseFixture current test case fixture.
  #  */
  def evaluate(scenario: [], spec: nil)
    raise 'Scenario or spec cannot be nil.' if scenario.empty? || spec.nil?

    rule = spec.rule
    retval = []

    rule.outcomes.each do |outcome|
      clause = rule.clause(outcome: outcome)
      rule_evaluator = RuleEvaluator.new(converters: spec.converters)

      rule_evaluator.parse(expression: clause)

      retval << rule_evaluator.evaluate(
        scenario: scenario,
        rule_token_convert: spec.converters
      )
    end
    retval
  end
end
