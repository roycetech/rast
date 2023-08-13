# frozen_string_literal: true

require 'factory_bot'
require 'rast/parameter_generator'

# Main DSL. This is the entry point of the test when running a spec.
class SpecDSL
  include FactoryBot::Syntax::Methods

  attr_accessor :subject, :execute_block,
                :prepare_block, :outcomes, :fixtures, :spec_id

  # # yaml-less
  attr_writer :variables, :exclude, :include, :converters, :rules, :pair,
              :default_outcome

  # @subject the sut instance
  # @name the sut name to be displayed with -fd
  def initialize(subject: nil, name: '', fixtures: [], spec_id: '', &block)
    @subject = subject
    @spec_id = spec_id

    # cannot derive name from subject when sut is a module.
    @subject_name = name || subject.class
    @fixtures = fixtures

    instance_eval(&block)
  end

  # yaml-less start
  def variables(vars)
    @variables = vars
  end

  def exclusion(clause)
    @exclude = clause
  end

  def inclusion(clause)
    @include = clause
  end

  def rules(rules)
    @rules = {}

    rules.each do |key, value|
      calc_key = key
      calc_key = key == :true if key == :true || key == :false
      @rules[calc_key] = value
    end
  end

  def outcomes(outcomes)
    rules(outcomes)
  end

  def default(default)
    @default_outcome = default
  end

  # yaml-less end

  def prepare(&block)
    @prepare_block = block
  end

  def execute(&block)
    @execute_block = block

    if @fixtures.nil?
      parameter_generator = ParameterGenerator.new
      parameter_generator.specs_config = { @spec_id => {
        'variables' => @variables,
        'pair' => @pair,
        'converters' => @converters,
        'rules' => @rules,
        'exclude' => @exclude,
        'include' => @include,
        'default' => @default_outcome
      } }

      @fixtures = parameter_generator.generate_fixtures(spec_id: @spec_id)
    end

    @fixtures.sort_by! do |fixture|
      if fixture[:expected].nil?
        raise "Expected outcome not found for #{fixture[:scenario]}, check" \
              ' your single rule/else/default configuration'
      end

      fixture[:expected] + fixture[:scenario].to_s
    end

    generate_rspecs
  end

  private

  def generate_rspecs
    main_scope = self

    RSpec.describe build_title do
      main_scope.fixtures.each do |fixture|
        generate_rspec(
          scope: main_scope,
          scenario: fixture[:scenario],
          expected: fixture[:expected]
        )
      end
    end
  end
end

def build_title
  title = "#{@subject_name}: #{@fixtures.first[:spec].description}"
  title += append_exclusion_title
  title += append_inclusion_title
  title
end

def append_exclusion_title
  exclusion = @fixtures.first[:spec].exclude_clause
  exclusion = exclusion.join if exclusion.is_a? Array
  exclusion ? ", EXCLUDE: '#{exclusion}'" : ''
end

def append_inclusion_title
  inclusion = @fixtures.first[:spec].include_clause
  inclusion = inclusion.join if inclusion.is_a? Array
  inclusion ? ", ONLY: '#{inclusion}'" : ''
end

def generate_rspec(scope: nil, scenario: {}, expected: '')
  it _it_title(expected, scenario) do
    block_params = scenario.values

    @mysubject = scope.subject

    class << self
      define_method(:subject) { @mysubject }
    end

    unless scope.prepare_block.nil?
      instance_exec(*block_params, &scope.prepare_block)
    end

    actual = execute_and_format_result(scope, block_params)
    expect(actual).to eq(expected)
  end
end

def execute_and_format_result(scope, block_params)
  actual = scope.execute_block.call(*block_params)
  actual.nil? ? 'nil' : actual.to_s
end

def _it_title(expected, scenario)
  spec_params = scenario.keys.inject('') do |output, key|
    build_it(scenario, output, key)
  end

  "[#{expected}]=[#{spec_params}]"
end

def build_it(scenario, output, key)
  output += ', ' unless output == ''
  calc_key = scenario[key].nil? ? 'nil' : scenario[key]
  output + "#{key}: #{calc_key}"
end

# DSL Entry Point
def spec(subject: nil, name: '', fixtures: [], spec_id: '', &block)
  SpecDSL.new(
    subject: subject,
    name: name,
    fixtures: fixtures,
    spec_id: spec_id,
    &block
  )
end
