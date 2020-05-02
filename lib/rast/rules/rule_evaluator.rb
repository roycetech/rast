# frozen_string_literal: true

require 'rast/rules/operator'
require 'rast/rules/logic_helper'
require 'rast/converters/int_converter'
require 'rast/converters/float_converter'
require 'rast/converters/bool_converter'
require 'rast/converters/str_converter'

# Evaluates the rules.
class RuleEvaluator
  include LogicHelper

  NOT = Operator.new(name: 'not', symbol: '!', precedence: 100)
  AND = Operator.new(name: 'and', symbol: '&', precedence: 2)
  OR = Operator.new(name: 'or', symbol: '|', precedence: 1)

  OPERATORS = [NOT, AND, OR].freeze
  OPERATORS_CONCAT = OPERATORS.map(&:to_s).join

  # the "false" part of the "false[1]"
  RE_TOKEN_BODY = /^.+(?=\[)/.freeze
  RE_TOKENS = /([!|)(&])|([a-zA-Z\s0-9-]+\[\d\])/.freeze

  def self.operator_from_symbol(symbol: nil)
    OPERATORS.find { |operator| operator.symbol == symbol }
  end

  DEFAULT_CONVERT_HASH = {
    Integer => IntConverter.new,
    Float => FloatConverter.new,
    Fixnum => FloatConverter.new,
    TrueClass => BoolConverter.new,
    FalseClass => BoolConverter.new,
    String => StrConverter.new
  }.freeze

  # /** @param pConverterList list of rule token converters. */
  def initialize(converters: [])
    @converters = converters

    @stack_operations = []
    @stack_rpn = []
    @stack_answer = []
  end

  # /**
  #  * Parses the math expression (complicated formula) and stores the result.
  #  *
  #  * @param pExpression <code>String</code> input expression (logical
  #  *            expression formula)
  #  * @since 0.3.0
  #  */
  def parse(expression: '')
    # /* cleaning stacks */
    @stack_operations.clear
    @stack_rpn.clear

    if expression.is_a?(Array)
      tokens = expression
    else
      tokens = RuleEvaluator.tokenize(clause: expression)
    end


    # /* loop for handling each token - shunting-yard algorithm */
    tokens.each { |token| shunt_internal(token: token.strip) }

    @stack_rpn << @stack_operations.pop while @stack_operations.any?
    @stack_rpn.reverse!
  end

  # splitting input string into tokens
  # @ clause - rule clause to be tokenized
  def self.tokenize(clause: '')
    clause.to_s.split(RE_TOKENS).reject(&:empty?)
  end

  # /**
  #  * Evaluates once parsed math expression with "var" variable included.
  #  *
  #  * @param scenario List of values to evaluate against the rule expression.
  #  * @param rule_token_convert mapping of rule tokens to converter.
  #  * @return <code>String</code> representation of the result
  #  */
  def evaluate(scenario: [], rule_token_convert: {})
    # /* check if is there something to evaluate */
    if @stack_rpn.empty?
      true
    elsif @stack_rpn.size == 1
      evaluate_one_rpn(scenario: scenario).to_s
    else
      evaluate_multi_rpn(
        scenario: scenario,
        rule_token_convert: rule_token_convert
      )
    end
  end

  # /**
  #  * @param rule_token_convert token to converter map.
  #  * @param default_converter default converter to use.
  #  */
  def next_value(rule_token_convert: {}, default_converter: nil)
    subscript = -1
    retval = []
    value = @stack_answer.pop
    if TRUE != value && FALSE != value
      subscript = extract_subscript(token: value.to_s)
      value_str = value.to_s.strip
      if subscript > -1
        converter = @converters[subscript]
        value = converter.convert(value_str[/^.+(?=\[)/])
      else
        value = if rule_token_convert.nil? ||
                   rule_token_convert[value_str].nil?
                  default_converter.convert(value_str)
                else
                  rule_token_convert[value_str].convert(value_str)
                end
      end
    end
    retval << subscript
    retval << value
    retval
  end

  # /** @param token token. */
  def shunt_internal(token: '')
    if open_bracket?(token: token)
      @stack_operations << token
    elsif close_bracket?(token: token)
      while @stack_operations.any? &&
            !open_bracket?(token: @stack_operations.last.strip)
        @stack_rpn << @stack_operations.pop
      end
      @stack_operations.pop
    elsif operator?(token: token)
      while !@stack_operations.empty? &&
            operator?(token: @stack_operations.last.strip) &&
            precedence(symbol_char: token[0]) <=
            precedence(symbol_char: @stack_operations.last.strip[0])
        @stack_rpn << @stack_operations.pop
      end
      @stack_operations << token
    else
      @stack_rpn << token
    end
  end

  private

  # /**
  #  * Returns value of 'n' if rule token ends with '[n]'. where 'n' is the
  #  * variable group index.
  #  *
  #  * @param string token to check for subscript.
  #  */
  def extract_subscript(token: '')
    subscript = token[/\[(\d+)\]$/, 1]
    subscript.nil? ? -1 : subscript.to_i
  end

  # /**
  #  * @param scenario List of values to evaluate against the rule expression.
  #  * @param rule_token_convert token to converter map.
  #  */
  def evaluate_multi_rpn(scenario: [], rule_token_convert: {})
    # /* clean answer stack */
    @stack_answer.clear

    # /* get the clone of the RPN stack for further evaluating */
    stack_rpn_clone = Marshal.load(Marshal.dump(@stack_rpn))

    # /* evaluating the RPN expression */

    # binding.pry

    while stack_rpn_clone.any?
      token = stack_rpn_clone.pop.strip
      if operator?(token: token)
        if NOT.symbol == token
          evaluate_multi_not(scenario: scenario)
        else
          evaluate_multi(
            scenario: scenario,
            rule_token_convert: rule_token_convert,
            operator: RuleEvaluator.operator_from_symbol(symbol: token[0])
          )
        end
      else
        @stack_answer << token
      end
    end

    raise 'Some operator is missing' if @stack_answer.size > 1

    last = @stack_answer.pop
    last[1..last.size]
  end

  # /**
  #  * @param scenario List of values to evaluate against the rule expression.
  #  * @param rule_token_convert token to converter map.
  #  * @param operator OR/AND.
  #  */
  def evaluate_multi(scenario: [], rule_token_convert: {}, operator: nil)
    default_converter = DEFAULT_CONVERT_HASH[scenario.first.class]

    # binding.pry

    left_arr = next_value(
      rule_token_convert: rule_token_convert,
      default_converter: default_converter
    )

    right_arr = next_value(
      rule_token_convert: rule_token_convert,
      default_converter: default_converter
    )

    answer = send(
      "perform_logical_#{operator.name}",
      scenario: scenario,
      left_subscript: left_arr[0],
      right_subscript: right_arr[0],
      left: left_arr[1],
      right: right_arr[1]
    )

    @stack_answer << if answer[0] == '|'
                       answer
                     else
                       "|#{answer}"
                     end
  end

  # /**
  #  * @param scenario List of values to evaluate against the rule expression.
  #  */
  def evaluate_multi_not(scenario: [])
    left = @stack_answer.pop.strip

    # binding.pry

    answer = if LogicHelper::TRUE == left
               LogicHelper::FALSE
             elsif LogicHelper::FALSE == left
               LogicHelper::TRUE
             else
               subscript = extract_subscript(token: left)
               if subscript < 0
                 (!scenario.include?(left)).to_s
               else
                 default_converter = DEFAULT_CONVERT_HASH[scenario.first.class]
                 converted = default_converter.convert(left[RE_TOKEN_BODY])
                 (scenario[subscript] == converted).to_s
               end
             end

    @stack_answer << if answer[0] == '|'
                       answer
                     else
                       "|#{answer}"
                     end
  end

  # /** @param scenario to evaluate against the rule expression. */
  def evaluate_one_rpn(scenario: [])
    single = @stack_rpn.last
    subscript = extract_subscript(token: single)
    default_converter = DEFAULT_CONVERT_HASH[scenario.first.class]
    if subscript > -1
      scenario[subscript] == default_converter.convert(single[RE_TOKEN_BODY])
    else
      scenario.include?(default_converter.convert(single))
    end
  end

  def operator?(token: '')
    !token.nil? && OPERATORS.map(&:symbol).include?(token)
  end

  def precedence(symbol_char: '')
    RuleEvaluator.operator_from_symbol(symbol: symbol_char).precedence
  end
end
