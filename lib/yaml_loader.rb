# frozen_string_literal: true

require 'yaml'

require './lib/rast_spec'
require './lib/rules/rule'

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

    return spec unless spec_config['converters'].any?

    converters = spec_config['converters'].map do |converter|
      Object.const_get(converter).new
    end
    spec.init_converters(converters: converters)
  end
end
