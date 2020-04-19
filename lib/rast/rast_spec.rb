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
    @pair_reversed = [@pair.to_a.first.reverse].to_h
    self
  end

  def init_converters(converters: [])
    @converters = converters
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
