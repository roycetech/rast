# frozen_string_literal: true

require 'pry'
require 'yaml'
require 'rast/rast_spec'
require 'rast/rules/rule'
require 'rast/rules/rule_evaluator'
require 'rast/rules/rule_validator'

require 'rast/converters/float_converter'

# Generates the test parameters.
class ParameterGenerator
  # Allow access so yaml-less can build the config via dsl.
  attr_accessor :specs_config

  def initialize(yaml_path: '')
    @specs_config = YAML.load_file(yaml_path)['specs'] if File.exist? yaml_path
  end

  # addCase. Generate the combinations, then add the fixture to the final list
  def generate_fixtures(spec_id: '')
    return nil if @specs_config.nil?

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
    return true if spec.exclude_clause.nil?

    exclude_clause = spec.exclude_clause
    rule_evaluator = RuleEvaluator.new(converters: spec.converters)
    rule_evaluator.parse(expression: exclude_clause)

    rule_evaluator.evaluate(scenario: scenario, rule_token_convert: spec.token_converter) == "false"
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

    spec.variables.keys.zip(scenario) do |array|
      var_name = array.first.to_sym
      var_value = array.last
      param[:scenario][var_name] = var_value
    end

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

    spec.init_exclusion(spec_config['exclude']) unless spec_config['exclude'].nil?

    converters = if spec_config['converters'].nil?
                   str_converter = StrConverter.new
                   spec_config['variables'].map { |_var| str_converter }
                 elsif spec_config['converters'].first.class == String
                   spec_config['converters'].map do |converter|
                     Object.const_get(converter).new
                   end
                 else
                   spec_config['converters']
                 end

    spec.init_converters(converters: converters)
  end
end
