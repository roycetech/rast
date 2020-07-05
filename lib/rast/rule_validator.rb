# frozen_string_literal: true

require 'rast/rules/rule_processor'

# Validates rules
class RuleValidator
  def validate(scenario: [], fixture: {})
    spec = fixture[:spec]
    rule_processor = RuleProcessor.new(
      rule: spec.rule,
      token_converters: spec.token_converter
    )

    rule_result = rule_processor.evaluate(scenario: scenario)

    spec = fixture[:spec]
    validate_results(scenario, rule_result, spec)
  end

  private

  # @returns string
  def validate_results(scenario, rule_result, spec)
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

  def validate_multi(scenario: [], spec: nil, rule_result: [])
    matched_outputs = []
    match_count = 0

    to_boolean(string_list: rule_result).each_with_index do |result, i|
      next unless result

      match_count += 1
      matched_outputs << spec.rule.outcomes[i]
    end

    verify_results(spec, scenario, matched_outputs, match_count)

    matched_outputs.first || spec.default_outcome
  end

  # @returns array of boolean from array of strings. 'true' becomes true.
  def to_boolean(string_list: [])
    string_list.map do |result|
      result.to_s == 'true'
    end
  end

  def verify_results(spec, scenario, matched_outputs, match_count)
    Rast.assert("#{spec.description} #{scenario} must fall into a unique rule" \
      " outcome/clause, matched: #{matched_outputs}") do
      match_count == 1 || match_count.zero? && !spec.default_outcome.nil?
    end
  end

  def binary_outcome(outcome: '', spec: nil, expected: false)
    if expected == 'true'
      outcome
    else
      spec.pair[outcome]
    end
  end
end
