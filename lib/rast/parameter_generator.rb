# frozen_string_literal: true

require 'pry'
require 'yaml'
require_relative 'rast_spec'
require_relative 'rules/rule'
require_relative 'rules/rule_evaluator'
require_relative 'rules/rule_validator'

require_relative 'converters/float_converter'

# Generates the test parameters.
class ParameterGenerator
  def initialize(yaml_path: '')
    @specs_config = YAML.load_file(yaml_path)['specs']

    # p @specs_config
  end

  # addCase. Generate the combinations, then add the fixture to the final list
  def generate_fixtures(spec_id: '')
    spec_config = @specs_config[spec_id]

    spec_config[:description] = spec_id
    spec = instantiate_spec(spec_config)

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
    rule_evaluator = RuleEvaluator.new(converters: spec.converters)
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
    param = { spec: spec, scenario: {} }
    token_converter = {}

    spec.variables.keys.each_with_index do |key, index|
      spec.variables[key].each do |element|
        unless spec.converters.nil?
          token_converter[element.to_s] = spec.converters[index]
        end
      end
    end

    spec.variables.keys.zip(scenario) do |array|
      var_name = array.first.to_sym
      var_value = array.last
      param[:scenario][var_name] = var_value
    end

    param[:converter_hash] = token_converter
    param[:expected_outcome] = validator.validate(
      scenario: scenario,
      fixture: param
    )

    param
  end

  def instantiate_spec(spec_config)
    spec = RastSpec.new(
      description: spec_config[:description],
      variables: spec_config['variables'],
      rule: Rule.new(rules: spec_config['rules'])
    )

    pair_config = spec_config['pair']
    spec.init_pair(pair_config: pair_config) unless pair_config.nil?

    converters = if spec_config['converters'].nil?
                   str_converter = StrConverter.new
                   spec_config['variables'].map { |_var| str_converter }
                 else
                   spec_config['converters'].map do |converter|
                     Object.const_get(converter).new
                   end
                 end

    spec.init_converters(converters: converters)
  end
end
