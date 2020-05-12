# frozen_string_literal: true

require 'yaml'
require 'rast/rast_spec'
require 'rast/rules/rule'
require 'rast/rules/rule_evaluator'
require 'rast/rules/rule_validator'

require 'rast/converters/default_converter'

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
    spec_config['rules'] ||= spec_config['outcomes']
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
    return true if spec.exclude_clause.nil? && spec.include_clause.nil?

    rule_evaluator = RuleEvaluator.new(converters: spec.converters)

    exclude_result = true
    unless spec.exclude_clause.nil?
      exclude_clause = Rule.sanitize(clause: spec.exclude_clause)
      rule_evaluator.parse(expression: exclude_clause)
      exclude_result = rule_evaluator.evaluate(scenario: scenario, rule_token_convert: spec.token_converter) == "false"
    end

    return exclude_result if spec.include_clause.nil?

    include_clause = Rule.sanitize(clause: spec.include_clause)
    rule_evaluator.parse(expression: include_clause)
    rule_evaluator.evaluate(scenario: scenario, rule_token_convert: spec.token_converter) == "true"
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

  # Detects if rule config has one outcome to one token mapping.
  def one_to_one(outcome_to_clause)
    outcome_to_clause.each do |outcome, clause|
      next if clause.is_a?(Array) && clause.size == 1

      return false if RuleEvaluator.tokenize(clause: clause).size > 1
    end

    true
  end

  # Used to optimize by detecting the variables if rules config is a 1 outcome to 1 rule token.
  def detect_variables(spec_config)
    return nil unless one_to_one(spec_config['rules'])

    tokens = spec_config['rules'].values
    return { vars: tokens.map(&:first) } if tokens.first.is_a?(Array) && tokens.first.size == 1

    { vars: spec_config['rules'].values }
  end

  def instantiate_spec(spec_config)
    if spec_config['variables'].nil?
      spec_config['variables'] = detect_variables(spec_config)
    end

    spec = RastSpec.new(
      description: spec_config[:description],
      variables: spec_config['variables'],
      rule: Rule.new(rules: spec_config['rules'])
    )

    pair_config = calculate_pair(spec_config)
    spec.init_pair(pair_config: pair_config) unless pair_config.nil?

    unless spec_config['exclude'].nil?
      spec.init_exclusion(spec_config['exclude'])
    end

    unless spec_config['include'].nil?
      spec.init_inclusion(spec_config['include'])
    end

    converters_config = spec_config['converters']
    converters = if converters_config.nil?
                   # when no converters defined, we detect if type is consistent, otherwise assume it's string.
                   default_converter = DefaultConverter.new
                   spec_config['variables'].map do |_key, array|
                     if same_data_type(array)
                       RuleEvaluator::DEFAULT_CONVERT_HASH[array.first.class]
                     else
                       default_converter
                     end
                   end
                 elsif converters_config.first.class == String
                   # when converters defined, determined by the converter name as String.
                   spec_config['converters'].map do |converter|
                     Object.const_get(converter).new
                   end
                 else
                   # converters defined, probably programmatically when yaml-less, just return it.
                   converters_config
                 end

    spec.init_converters(converters: converters)
  end

  def calculate_pair(spec_config)
    pair_config = spec_config['pair']
    return pair_config unless pair_config.nil?

    outcomes = spec_config['rules'].keys
    if outcomes.size == 1
      if [TrueClass, FalseClass].include?(outcomes.first.class)
        return { outcomes.first => !outcomes.first }
      end

      if %w[true false].include?(outcomes.first)
        return { outcomes.first => outcomes.first == 'true' ? 'false' : 'true' }
      end

      return { outcomes.first => spec_config['else'] } if spec_config['else']
    end

    {}
  end

  def same_data_type(array)
    type = array.first.class
    array.each do |element|
      return false if element.class != type &&
                      ![FalseClass, TrueClass].include?(element.class)
    end
    true
  end
end
