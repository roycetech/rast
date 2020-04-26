# frozen_string_literal: true

require 'rspec'
require 'rast/parameter_generator'
require 'rast/spec_dsl'

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

  def initialize(rasted_subject, &block)
    @subject = if rasted_subject.class == Module
                 Class.new { extend rasted_subject }
               else
                 rasted_subject.new
               end

    @subject_name =rasted_subject

    spec_path = caller[2][/spec.*?\.rb/]
    yaml_path = spec_path.gsub(/(\w+).rb/, 'rast/\\1.yml')

    @generator = ParameterGenerator.new(yaml_path: yaml_path)

    instance_eval(&block)
  end

  def spec(id, &block)
    global_spec(
      subject: @subject,
      name: @subject_name,
      fixtures: @generator.generate_fixtures(spec_id: id),
      &block
    )
  end
end

# DSL Entry Point
def rast(rasted_subject, &block)
  Rast.new(rasted_subject, &block)
end
