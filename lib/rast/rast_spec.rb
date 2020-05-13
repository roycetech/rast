# frozen_string_literal: true

require 'rast/rules/rule_evaluator'

# CaseFixture.java, containing an actual and specific combination of variables.
class RastSpec
  # token_converter is the mapping of a variable token to a converter
  # converters is a list of converters used via positional tokens.
  attr_reader :variables, :pair, :pair_reversed, :rule, :description,
              :exclude_clause, :include_clause, :token_converter, :converters,
              :default_outcome

  attr_accessor :exclude

  def initialize(description: '', variables: [][], rule: nil, default_outcome: '')
    @description = description
    @variables = variables
    @pair = {}
    @pair_reversed = {}
    @rule = rule
    @exclude_clause = nil
    @include_clause = nil
    @default_outcome = default_outcome
  end

  def init_pair(pair_config: {})
    @pair[pair_config.keys.first.to_s] = pair_config.values.first.to_s

    array = [@pair.to_a.first.reverse].first
    @pair_reversed = { array.first.to_s => array.last }
    self
  end

  def init_converters(converters: [])
    @converters = converters
    @token_converter = {}

    @variables.keys.each_with_index do |key, index|
      @variables[key].each do |element|
        converter = RuleEvaluator::DEFAULT_CONVERT_HASH[element.class] || converters[index]
        @token_converter[element.to_s] = converter
      end
    end

    self
  end

  def init_exclusion(exclude_clause)
    @exclude_clause = exclude_clause
    self
  end

  def init_inclusion(include_clause)
    @include_clause = include_clause
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
