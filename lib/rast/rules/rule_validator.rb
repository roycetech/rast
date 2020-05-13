# frozen_string_literal: true

require 'rast/rules/rule_processor'

# Validates rules
class RuleValidator
  def validate(scenario: [], fixture: {})
    rule_result = RuleProcessor.new.evaluate(
      scenario: scenario,
      fixture: fixture
    )

    spec = fixture[:spec]
    rule = spec.rule

    single_result = rule.size == 1
    if single_result
      next_result = rule_result.first
      outcome = rule.outcomes.first
      binary_outcome(outcome: outcome, spec: spec, expected: next_result)
    else
      validate_multi(scenario: scenario, spec: spec, rule_result: rule_result)
    end
  end

  private

  def validate_multi(scenario: [], spec: nil, rule_result: [])
    matched_outputs = []
    match_count = 0

    rule_result.map { |result| result.to_s == 'true' }.each_with_index do |result, i|
      next unless result

      match_count += 1
      matched_outputs << spec.rule.outcomes[i]
    end

    Rast.assert("Scenario must fall into a unique rule outcome/clause:
     #{scenario} , matched: #{matched_outputs}") { match_count == 1  } if spec.default_outcome.nil?

    matched_outputs.first || spec.default_outcome
  end

  #
  def binary_outcome(outcome: '', spec: nil, expected: false)
    if expected == 'true'
      outcome
    else
      spec.pair[outcome]
    end
  end
end
