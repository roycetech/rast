# frozen_string_literal: true

require 'pry'
require './lib/yaml_loader'
require './lib/rules/rule_evaluator'
require './lib/rules/rule_validator'

# Generates the test parameters.
class ParameterGenerator
  def generate_data(yaml_path: '', id: nil)
    loader = YamlLoader.new(uri: yaml_path, id: id)
    loader.load
    generate_fixtures(spec: loader.spec)
  end

  # addCase. Generate the combinations, then add the fixture to the final list
  def generate_fixtures(spec: nil)
    list = []
    variables = spec.variables
    var_first = spec.variables.first
    multipliers = []

    (1...variables.size).each { |i| multipliers << variables.values[i].dup }
    scenarios = var_first.last.product(*multipliers)
    add_fixtures(scenarios: scenarios, spec: spec, list: list)
    list
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
    # binding.pry

    param = { spec: spec, scenario: {} }
    token_converter = {}

    spec.variables.keys.each_with_index do |key, index|
      spec.variables[key].each do |element|
        token_converter[element.to_s] = spec.converters[index] unless spec.converters.nil?
      end
    end

    spec.variables.keys.zip(scenario) do |array|
      var_name = array.first.to_sym
      var_value = array.last
      param[:scenario][var_name] = var_value
    end

    param[:converter_hash] = token_converter

    # binding.pry

    param[:expected_outcome] = validator.validate(
      scenario: scenario,
      fixture: param
    )

    param
  end
end
