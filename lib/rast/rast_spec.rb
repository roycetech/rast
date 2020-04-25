# frozen_string_literal: true

# CaseFixture.java, containing an actual and specific combination of variables.
class RastSpec
  attr_reader :variables, :pair, :pair_reversed, :rule, :description,
              :exclude_clause, :converters

  attr_accessor :exclude

  def initialize(description: '', variables: [][], rule: nil)
    @description = description
    @variables = variables
    @pair = {}
    @pair_reversed = {}
    @rule = rule
    @exclude_clause = nil
  end

  def init_pair(pair_config: {})
    @pair[pair_config.keys.first.to_s] = pair_config.values.first.to_s

    array = [@pair.to_a.first.reverse]
    @pair_reversed = { array.first.to_s.to_sym => array.last }
    self
  end

  def init_converters(converters: [])
    @converters = {}

    @variables.keys.each_with_index do |key, index|
      @variables[key].each do |element|
        @converters[element.to_s] = converters[index]
      end
    end

    self
  end

  def init_exclusion(exclude_clause)
    @exclude_clause = exclude_clause
    self
  end

  def to_s
    "Class: #{self.class}
Description: #{@description}
Variables: #{@variables}
Rules: #{@rules}
Pair: #{@pair}
Converters: #{@converters}
    "
  end
end
