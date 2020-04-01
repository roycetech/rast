# frozen_string_literal: true

require 'pry'
require './lib/yaml_loader'
require './lib/rules/rule_evaluator'
require './lib/rules/rule_validator'

# Generates the test parameters.
class ParameterGenerator
  def generate_data(yaml_path)
    loader = YamlLoader.new(yaml_path)
    loader.load

    specs = loader.specs

    retval = []
    specs.each { |spec| generate_fixtures(list: retval, spec: spec) }

    retval
  end

  # addCase. Generate the combinations, then add the fixture to the final list
  def generate_fixtures(list: nil, spec: nil)
    variables = spec.variables
    var_first = spec.variables.first
    multipliers = []

    (1...variables.size).each { |i| multipliers << variables.values[i].dup }

    scenarios = var_first.last.product(*multipliers)

    add_fixtures(scenarios: scenarios, spec: spec, list: list)
  end

  private

  def valid_case?(scenario, spec)
    return true if spec.exempt_rule.nil?

    exempt_rule = fixture.exempt_rule
    rule_evaluator = RuleEvaluator.new(spec.converters)
    rule_evaluator.parse(exempt_rule)
    !ruleEvaluator.evaluate(scenario, spec.converters)
  end

  # add all fixtures to the list.
  def add_fixtures(scenarios: [], spec: nil, list: [])
    validator = RuleValidator.new

    scenarios.each do |scenario|
      next unless valid_case?(scenario, spec)

      list << build_param(validator, scenario, spec)
    end
  end

  def build_param(validator, scenario, spec)

    param = {
      spec: spec,
      scenario: {},
      expected_outcome: validator.validate(scenario, spec)
    }

    spec.variables.keys.zip(scenario) do |array|
      param[:scenario][array.first.to_sym] = array.last
    end

    param
  end
end
