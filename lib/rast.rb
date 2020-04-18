# frozen_string_literal: true

require 'rspec'
require_relative 'rast/parameter_generator'
require_relative 'rast/spec_dsl'

# Main DSL. This is the entry point of the test when running a spec.
class Rast
# RSpec All scenario test
#
# Example:
#   >> Hola.hi("spanish")
#   => hola mundo
#
# Arguments:
#   language: (String)



  alias global_spec spec

  def initialize(rasted_class, &block)
    @rasted_class = rasted_class
    @subject = rasted_class.new

    spec_path = caller[2][/spec.*?\.rb/]
    yaml_path = spec_path.gsub(/(\w+).rb/, 'rast/\\1.yml')

    @generator = ParameterGenerator.new(yaml_path: yaml_path)

    instance_eval(&block)
  end

  def spec(id, &block)
    global_spec(
      subject: @subject,
      fixtures: @generator.generate_fixtures(spec_id: id),
      &block
    )
  end
end

# DSL Entry Point
def rast(rasted_class, &block)
  Rast.new(rasted_class, &block)
end
