# frozen_string_literal: true

require './lib/assert'
require './lib/rules/rule_processor'

# Validates rules
class RuleValidator
  def validate(scenario, spec)
    rule_result = RuleProcessor.new.evaluate(scenario: scenario, spec: spec)
    rule = spec.rule

    single_result = rule.size == 1
    if single_result
      next_result = rule_result.first
      outcome = rule.outcomes.first
      binary_outcome(outcome: outcome, spec: spec, expected: next_result)
    else
      validate_multi(scenario: scenario, spec: spec)
    end
  end

  private

  def validate_multi(scenario: [], spec: nil)
    matched_outputs = {}
    match_count = 0

    rule_result.each_with_index do |result, i|
      next unless result

      match_count += 1
      retval = spec.rules.keys[i]
      matched_outputs << retval
    end
    assert("Scenario must fall into a unique rule output/clause:
     #{scenario} , matched: #{matched_outputs}") { matchCount == 1 }
  end

  def binary_outcome(outcome: '', spec: nil, expected: false)
    is_positive = spec.pair.keys.include?(outcome)
    if is_positive
      expected == 'true' ? outcome : opposite(outcome: outcome, spec: spec)
    else
      expected == 'true' ? opposite(outcome: outcome, spec: spec) : outcome
    end
  end

  def opposite(outcome: '', spec: nil)
    if spec.pair.keys.include? outcome
      spec.pair[outcome]
    else
      spec.pair_reversed[outcome]
    end
  end
end
