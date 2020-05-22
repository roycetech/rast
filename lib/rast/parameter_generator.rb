# frozen_string_literal: true

require 'yaml'
require 'rast/rast_spec'
require 'rast/rules/rule'
require 'rast/rules/rule_evaluator'
require 'rast/rules/rule_validator'

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

    raise "Spec not found for: #{spec_id}. Check yaml file." if spec_config.nil?

    spec_config[:description] = spec_id

    # Keep, for backwards compatibility
    spec_config['rules'] ||= spec_config['outcomes']
    spec_config['default'] ||= spec_config['else']

    spec_config['variables'] = expand_variables(spec_config['variables'])

    spec = build_spec(spec_config)

    list = []

    variables = spec.variables
    var_first = variables.first
    multipliers = []

    (1...variables.size).each { |i| multipliers << variables.values[i].dup }
    scenarios = var_first.last.product(*multipliers)

    add_fixtures(scenarios: scenarios, spec: spec, list: list)
    list
  end

  private

  def expand_variables(variables)
    return nil unless variables

    expanded_variables = {}
    variables.each do |key, tokens|
      expanded_variables[key] = if tokens == 'boolean'
                                  [false, true]
                                else
                                  tokens
                                end
    end
    expanded_variables
  end

  def valid_case?(scenario, spec)
    return true unless with_optional_clause?(spec)

    include_result = true
    unless spec.exclude_clause.nil?
      include_result = qualify_secario?(spec, scenario, false)
    end

    return include_result if no_include_or_dont_include?(spec, include_result)

    qualify_secario?(spec, scenario, true)
  end

  # blech!
  def no_include_or_dont_include?(spec, include_result)
    spec.include_clause.nil? || !include_result
  end

  def qualify_secario?(spec, scenario, is_included)
    action = is_included ? 'include' : 'exclude'
    rule_evaluator = RuleEvaluator.new(converters: spec.converters)
    clause = Rule.sanitize(clause: spec.send("#{action}_clause"))
    rule_evaluator.parse(expression: clause)
    rule_evaluator.evaluate(
      scenario: scenario,
      rule_token_convert: spec.token_converter
    ) == is_included.to_s
  end

  # Has an exclude or include clause
  def with_optional_clause?(spec)
    !spec.exclude_clause.nil? || !spec.include_clause.nil?
  end

  # add all fixtures to the list.
  def add_fixtures(scenarios: [], spec: nil, list: [])
    validator = RuleValidator.new

    scenarios.each do |scenario|
      good = valid_case?(scenario, spec)
      # p "#{good} #{scenario}"

      next unless good

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

    param[:expected] = validator.validate(scenario: scenario, fixture: param)

    param
  end

  # Detects if rule config has one outcome to one token mapping.
  def one_to_one(outcome_to_clause)
    outcome_to_clause.each do |_outcome, clause|
      next if outcome_to_one_array?(clause)

      return false if RuleEvaluator.tokenize(clause: clause).size > 1
    end

    true
  end

  def outcome_to_one_array?(clause)
    clause.is_a?(Array) && clause.size == 1
  end

  # Used to optimize by detecting the variables if rules config is a 1 outcome
  # to 1 rule token.
  def detect_variables(spec_config)
    return nil unless one_to_one(spec_config['rules'])

    tokens = spec_config['rules'].values
    if tokens.first.is_a?(Array) && tokens.first.size == 1
      return { vars: tokens.map(&:first) }
    end

    { vars: spec_config['rules'].values }
  end

  def instantiate_spec(spec_config)
    RastSpec.new(
      description: spec_config[:description],
      variables: spec_config['variables'],
      rule: Rule.new(rules: spec_config['rules']),
      default_outcome: spec_config['default'] || spec_config['else']
    )
  end

  def build_spec(spec_config)
    if spec_config['variables'].nil?
      spec_config['variables'] = detect_variables(spec_config)
    end

    spec = instantiate_spec(spec_config)
    pair_config = calculate_pair(spec_config)
    spec.init_pair(pair_config: pair_config) unless pair_config.nil?

    configure_include_exclude(spec, spec_config)
    spec.init_converters(converters: generate_converters(spec_config))
  end

  def generate_converters(spec_config)
    converters_config = spec_config['converters']
    return converters unless converters_config.nil?

    # when no converters defined, we detect if type is consistent, otherwise
    # assume it's string.
    default_converter = DefaultConverter.new
    spec_config['variables'].map do |_key, array|
      if same_data_type(array)
        RuleEvaluator::DEFAULT_CONVERT_HASH[array.first.class]
      else
        default_converter
      end
    end
  end

  def configure_include_exclude(spec, spec_config)
    unless spec_config['exclude'].nil?
      spec.init_exclusion(spec_config['exclude'])
    end

    return if spec_config['include'].nil?

    spec.init_inclusion(spec_config['include'])
  end

  def calculate_pair(spec_config)
    pair_config = spec_config['pair']
    return pair_config unless pair_config.nil?

    outcomes = spec_config['rules'].keys
    return {} unless outcomes.size == 1

    boolean_pair = boolean_pair(outcomes, spec_config)
    return boolean_pair if boolean_pair

    default_pair(spec_config)
  end

  def default_pair(spec_config)
    outcomes = spec_config['rules'].keys
    { outcomes.first => spec_config['default'] } if spec_config['default']
  end

  # refactored out of calculate_pair.
  def boolean_pair(outcomes, spec_config)
    return false if spec_config['default']

    if [TrueClass, FalseClass].include?(outcomes.first.class)
      return { outcomes.first => !outcomes.first }
    end

    return unless %w[true false].include?(outcomes.first)

    { outcomes.first => (outcomes.first != 'true').to_s }
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
