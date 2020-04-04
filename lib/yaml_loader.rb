# frozen_string_literal: true

require 'yaml'

require './lib/rast_spec'
require './lib/rules/rule'
require './lib/converters/str_converter'
require './lib/converters/float_converter'

# Loads Spec Yaml
class YamlLoader
  attr_accessor :spec

  # @id - spec ID to load
  def initialize(uri: '', id: '')
    @uri = uri
    @id = id
  end

  def load
    yaml = YAML.load_file(@uri)['specs']

    @id = yaml.keys.first if @id.empty?

    spec_config = yaml[@id]
    spec_config[:description] = @id
    @spec = instantiate_spec(spec_config)
  end

  private

  def instantiate_spec(spec_config)
    spec = RastSpec.new(
      description: spec_config[:description],
      variables: spec_config['variables'],
      rule: Rule.new(rules: spec_config['rules'])
    )

    pair_config = spec_config['pair']
    spec.init_pair(pair_config: pair_config) unless pair_config.nil?

    converters = if spec_config['converters'].nil?
                   str_converter = StrConverter.new
                   spec_config['variables'].map { |_var| str_converter }
                 else
                   spec_config['converters'].map do |converter|
                     Object.const_get(converter).new
                   end
                 end
    # binding.pry

    spec.init_converters(converters: converters)
  end
end
