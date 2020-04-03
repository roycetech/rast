# frozen_string_literal: true

require './lib/parameter_generator'

# Main DSL
class RastDSL
  attr_accessor :subject, :rspec_methods, :execute_block, :prepare_block, :transients

  def initialize(rasted_class, &block)
    @rasted_class = rasted_class
    @transients = []
    @result = nil
    @rspec_methods = []
    instance_eval(&block)
  end

  def prepare(&block)
    @prepare_block = block
    @transients
  end

  def set(key, value)
    @transients[key] = value
  end

  def get(key)
    @transients[key]
  end

  def result(outcome)
    @outcome = outcome
  end

  def respond_to_missing?
    super
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

  def execute(&block)
    @execute_block = block
    @subject = @rasted_class.new

    spec_path = caller[0][/spec.*?\.rb/]
    yaml_path = spec_path.gsub(/\.rb/, '.yml')

    param_generator = ParameterGenerator.new
    fixtures = param_generator.generate_data(yaml_path)
    fixtures.sort_by! { |fixture| fixture[:expected_outcome] }

    spec = fixtures.first[:spec]
    generate_rspecs(fixtures: fixtures, spec: spec)
  end

  private

  def generate_rspecs(fixtures: [], spec: nil)
    main_scope = self
    prepare_block = @prepare_block

    RSpec.describe "#{@rasted_class}: #{spec.description}" do
      fixtures.each do |fixture|
        params = fixture[:scenario].values

        prepare_block&.call(*params)

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
  params = scenario.keys.inject('') do |output, key|
    output += ', ' unless output == ''
    output + "#{key}: #{scenario[key]}"
  end
  it "[#{expected}]=[#{params}]" do
    block_params = scenario.values
    scope.prepare_block&.call(*block_params) unless scope.rspec_methods.any?

    while scope.rspec_methods.any?
      allow_meth = scope.rspec_methods.shift
      allow_mock = send(allow_meth[:name], allow_meth[:args])
      receive_meth = scope.rspec_methods.shift

      receive_result = send(receive_meth[:name], receive_meth[:args])

      receive_result.instance_eval { receive_meth[:block].call }
      to_meth = scope.rspec_methods.shift
      allow_mock.send(to_meth[:name], receive_result)
    end

    actual = scope.execute_block.call(*block_params).to_s

    expect(actual).to eq(expected)
  end
end

# DSL Entry Point
def rast(rasted_class, &block)
  RastDSL.new(rasted_class, &block)
end
