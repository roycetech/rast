# frozen_string_literal: true

require 'yaml'

require './lib/rast_spec'
require './lib/rules/rule'
require './lib/converters/str_converter'

# Loads Spec Yaml
class YamlLoader
  attr_accessor :specs

  def initialize(uri)
    @uri = uri

    @specs = []
  end

  def load
    yaml = YAML.load_file(@uri)['specs']

    yaml.keys.each do |key|
      spec_config = yaml[key]
      @specs << instantiate_spec(spec_config)
    end
  end

  private

  def instantiate_spec(spec_config)
    spec = RastSpec.new(
      description: spec_config['description'],
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
