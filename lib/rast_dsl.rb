# frozen_string_literal: true

require './lib/parameter_generator'

# Main DSL
class RastDSL
  attr_accessor :subject

  def initialize(rasted_class, &block)
    @rasted_class = rasted_class
    @transients = []
    @result = nil
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

  def execute(&block)
    @execute_block = block
    @subject = @rasted_class.new

    spec_path = caller[0][/spec.*?\.rb/]
    yaml_path = spec_path.gsub(/\.rb/, '.yml')

    param_generator = ParameterGenerator.new
    fixtures = param_generator.generate_data(yaml_path)

    generate_rspecs(fixtures: fixtures)
  end

  def generate_rspecs(fixtures: [])
    fixtures.each do |fixture|
      @prepare_block.call(*fixture[:scenario].values)
      actual = @execute_block.call.to_s

      generate_rspec(
        description: fixture[:spec].description,
        scenario: fixture[:scenario],
        expected: fixture[:expected_outcome],
        actual: actual
      )
    end
  end

  def generate_rspec(description: '', scenario: [], expected: '', actual: '')
    RSpec.describe "#{@rasted_class}: #{description}" do
      describe "given: #{scenario}" do
        it "results to: #{expected}" do
          expect(actual).to eq(expected)
        end
      end
    end
  end
end

def rast(rasted_class, &block)
  RastDSL.new(rasted_class, &block)
end
