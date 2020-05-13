# frozen_string_literal: true

require 'factory_girl'
require 'rast/parameter_generator'

# Main DSL. This is the entry point of the test when running a spec.
class SpecDSL
  include FactoryGirl::Syntax::Methods

  attr_accessor :subject, :rspec_methods, :execute_block,
                :prepare_block, :transients, :outcomes, :fixtures

  # # yaml-less
  attr_writer :variables, :exclude, :include, :converters, :rules, :pair, :default_outcome

  # @subject the sut instance
  # @name the sut name to be displayed with -fd
  def initialize(subject: nil, name: '', fixtures: [], spec_id: '', &block)
    @subject = subject
    @spec_id = spec_id

    # cannot derive name from subject when sut is a module.
    @subject_name = name || subject.class
    @fixtures = fixtures

    @transients = []
    @rspec_methods = []

    instance_eval(&block)
  end

  # yaml-less start
  def variables(vars)
    @variables = vars
  end

  def exclude(clause)
    @exclude = clause
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

  def pair(pair)
    @pair = pair
  end

  def default_outcome(outcome)
    @default_outcome = outcome
  end

  # yaml-less end

  def prepare(&block)
    @prepare_block = block
    @transients
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
        'exclude' => @exclude
      } }

      @fixtures = parameter_generator.generate_fixtures(spec_id: @spec_id)
    end

    @fixtures.sort_by! do |fixture|

      if fixture[:expected_outcome].nil?
        raise 'Broken initialization, check your single rule/else configuration'
      end

      fixture[:expected_outcome] + fixture[:scenario].to_s
    end

    # @fixtures.reverse!

    generate_rspecs
  end

  private

  def generate_rspecs
    main_scope = self

    title = "#{@subject_name}: #{@fixtures.first[:spec].description}"

    exclusion = fixtures.first[:spec].exclude_clause
    title += ", EXCLUDE: '#{exclusion}'" if exclusion
    inclusion = fixtures.first[:spec].include_clause
    title += ", ONLY: '#{inclusion}'" if inclusion

    RSpec.describe title do
      main_scope.fixtures.each do |fixture|
        generate_rspec(
          scope: main_scope,
          scenario: fixture[:scenario],
          expected: fixture[:expected_outcome]
        )
      end
    end
  end
end

def generate_rspec(scope: nil, scenario: {}, expected: '')
  spec_params = scenario.keys.inject('') do |output, key|
    output += ', ' unless output == ''
    calc_key = scenario[key].nil? ? nil : scenario[key]
    output + "#{key}: #{calc_key}"
  end

  it "[#{expected}]=[#{spec_params}]" do
    block_params = scenario.values

    @mysubject = scope.subject

    class << self
      define_method(:subject) { @mysubject }
    end

    if scope.rspec_methods.size > 0 || !scope.prepare_block.nil?
      instance_exec(*block_params, &scope.prepare_block)
    end

    actual = scope.execute_block.call(*block_params).to_s

    expect(actual).to eq(expected)
  end
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
