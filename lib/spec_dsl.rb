# frozen_string_literal: true

require './lib/parameter_generator'

# Main DSL. This is the entry point of the test when running a spec.
class RastDSL
  attr_accessor :subject, :rspec_methods, :execute_block, :prepare_block,
                :transients, :outcomes

  def initialize(rasted_class, &block)
    # binding.pry

    @rasted_class = rasted_class
    @transients = []
    @result = nil
    @rspec_methods = []
    @subject = rasted_class.new
    @outcomes = []

    spec_path = caller[2][/spec.*?\.rb/]
    yaml_path = spec_path.gsub(/(\w+).rb/, 'rast/\\1.yml')

    @generator = ParameterGenerator.new(yaml_path: yaml_path)

    instance_eval(&block)
  end

  def set(key, value)
    @transients[key] = value
  end

  def get(key)
    @transients[key]
  end

  def result(outcome)
    @outcomes << outcome.to_s
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

  def spec(id, &block)
    # p "#{id} specing...."
    @id = id

    instance_eval(&block)
  end

  def prepare(&block)
    # p 'Preparing'

    @prepare_block = block
    @transients
  end

  def execute(&block)
    # p 'Executing'
    @execute_block = block

    fixtures = @generator.generate_data(spec_id: @id)

    fixtures.sort_by! { |fixture| fixture[:expected_outcome] }

    spec = fixtures.first[:spec]
    generate_rspecs(fixtures: fixtures, spec: spec)
  end

  private

  def generate_rspecs(fixtures: [], spec: nil)
    main_scope = self

    RSpec.describe "#{@rasted_class}: #{spec.description}" do
      fixtures.each do |fixture|
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

    yo = scope.execute_block.call(*block_params).to_s

    # p '-----------------------'
    # p yo
    # p scope.outcomes

    expect(scope.outcomes.shift).to eq(expected)
  end
end

# DSL Entry Point
def rast(rasted_class, &block)
  # p "Entering DSL: #{rasted_class}"
  RastDSL.new(rasted_class, &block)
end
