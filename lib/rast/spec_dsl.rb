# frozen_string_literal: true

require_relative 'parameter_generator'

# Main DSL. This is the entry point of the test when running a spec.
class SpecDSL
  attr_accessor :subject, :rspec_methods, :execute_block, :prepare_block,
                :transients, :outcomes, :fixtures

  def initialize(subject: nil, fixtures: [], &block)
    @subject = subject
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
    return super if method_name_symbol == :to_ary

    @rspec_methods << {
      name: method_name_symbol,
      args: args.first,
      block: block
    }

    self
  end

  def prepare(&block)
    @prepare_block = block
    @transients
  end

  def execute(&block)
    @execute_block = block

    @fixtures.sort_by! { |fixture| fixture[:expected_outcome] + fixture[:scenario].to_s }
    generate_rspecs
  end

  private

  def generate_rspecs
    spec = @fixtures.first[:spec]
    main_scope = self

    RSpec.describe "#{@subject.class}: #{spec.description}" do
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
    scope.prepare_block&.call(*block_params) unless scope.rspec_methods.any?

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
def spec(subject: nil, fixtures: [], &block)
  SpecDSL.new(subject: subject, fixtures: fixtures, &block)
end
