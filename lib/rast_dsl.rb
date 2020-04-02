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

  private

  def generate_rspecs(fixtures: [])
    fixtures.each do |fixture|
      params = fixture[:scenario].values
      @prepare_block&.call(*params)
      actual = @execute_block.call(*params).to_s

      generate_rspec(
        description: fixture[:spec].description,
        scenario: fixture[:scenario],
        expected: fixture[:expected_outcome],
        actual: actual
      )
    end
  end

  def generate_rspec(description: '', scenario: [], expected: '', actual: '')
    given = scenario_text(scenario: scenario)
    RSpec.describe "#{@rasted_class}: #{description}" do
      describe "given: #{given}" do
        it "given: #{given} produces: [#{expected}]" do
          expect(actual).to eq(expected)
        end
      end
    end
  end

  def scenario_text(scenario: {})
    # binding.pry
    scenarios = scenario.to_a
    if scenarios.size == 1
      "#{scenarios.first.first} is [#{scenarios.first.last}]"
    elsif scenarios.size == 2
      "#{scenarios.first.first}=#{scenarios.first.last} and #{scenarios.last.first}=#{scenarios.last.last}"
    end
  end
end

def rast(rasted_class, &block)
  RastDSL.new(rasted_class, &block)
end
