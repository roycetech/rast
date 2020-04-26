# frozen_string_literal: true

require 'factory_girl'
require 'rast/parameter_generator'

# Main DSL. This is the entry point of the test when running a spec.
class SpecDSL
  include FactoryGirl::Syntax::Methods

  attr_accessor :subject, :rspec_methods, :execute_block,
                :prepare_block, :transients, :outcomes, :fixtures

  # # yaml-less
  attr_writer :variables, :exclude, :converters, :rules, :pair

  # @subject the sut instance
  # @name the sut name to be displayed with -fd
  def initialize(subject: nil, name: '', fixtures: [], spec_id: '', &block)
    @subject = subject
    @spec_id = spec_id

    # cannot derive name from subject when sut is a module.
    @subject_name = name || subject.class
    @fixtures = fixtures

    @transients = []
    @result = nil
    @rspec_methods = []

    instance_eval(&block)
  end

  def result(outcome)
    @outcome = outcome.to_s
  end

  def respond_to_missing?(*several_variants)
    super(several_variants)
  end

  def method_missing(method_name_symbol, *args, &block)
    # p "method_missing: #{method_name_symbol}"
    return super if method_name_symbol == :to_ary

    @rspec_methods << {
      name: method_name_symbol,
      args: args.first,
      block: block
    }

    self
  end

  # yaml-less start
  def variables(vars)
    @variables = vars
  end

  def exclude(clause)
    @exclude = clause
  end

  def converters(&block)
    @converters = instance_eval(&block)
  end

  def rules(rules)
    @rules = rules
  end

  def pair(pair)
    @pair = pair
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
      fixture[:expected_outcome] + fixture[:scenario].to_s
    end

    generate_rspecs
  end

  private

  def generate_rspecs
    spec = @fixtures.first[:spec]
    main_scope = self

    RSpec.describe "#{@subject_name}: #{spec.description}" do
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
    output + "#{key}: #{scenario[key]}"
  end

  it "[#{expected}]=[#{spec_params}]" do
    block_params = scenario.values

    if scope.rspec_methods.size > 0 || !scope.prepare_block.nil?
      scope.prepare_block.call(*block_params)
    end

    while scope.rspec_methods.any?
      first_meth = scope.rspec_methods.shift
      second_meth = scope.rspec_methods.shift
      if first_meth[:name] == :allow && second_meth[:name] == :receive
        allow(scope.subject)
          .to receive(second_meth[:args], &second_meth[:block])
      end
      scope.rspec_methods.shift
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
