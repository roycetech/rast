# frozen_string_literal: true

require 'rast/rules/operator'
require 'rast/rules/token_util'
require 'rast/rules/logic_helper'
require 'rast/converters/int_converter'
require 'rast/converters/float_converter'
require 'rast/converters/default_converter'
require 'rast/converters/bool_converter'
require 'rast/converters/str_converter'

# Evaluates the rules. "Internal refers to the `*true` or `*false` results."
class RuleEvaluator
  include LogicHelper

  NOT = Operator.new(name: 'not', symbol: '!', precedence: 100)
  AND = Operator.new(name: 'and', symbol: '&', precedence: 2)
  OR = Operator.new(name: 'or', symbol: '|', precedence: 1)

  OPERATORS = [NOT, AND, OR].freeze
  OPERATORS_CONCAT = OPERATORS.map(&:to_s).join

  # the "false" part of the "false[1]"
  RE_TOKEN_BODY = /^.+(?=\[)/.freeze
  RE_TOKENS = /([!|)(&])|([*a-zA-Z\s0-9-]+\[\d\])/.freeze

  def self.operator_from_symbol(symbol: nil)
    OPERATORS.find { |operator| operator.symbol == symbol }
  end

  DEFAULT_CONVERT_HASH = {
    Integer => IntConverter.new,
    Float => FloatConverter.new,
    Fixnum => IntConverter.new,
    Array => DefaultConverter.new,
    TrueClass => BoolConverter.new,
    FalseClass => BoolConverter.new,
    String => StrConverter.new,
    NilClass => DefaultConverter.new
  }.freeze

  # /** @param token_converters token to converter mapping */
  def initialize(token_converters: {})
    @token_converters = token_converters

    @stack_operations = []
    @stack_rpn = []
    @stack_answer = []
  end

  # /**
  #  * Parses the math expression (complicated formula) and stores the result.
  #  *
  #  * @param pExpression <code>String</code> input expression (logical
  #  *            expression formula)
  #  * @return void.
  #  * @since 0.3.0
  #  */
  def parse(expression: '')
    # /* cleaning stacks */
    @stack_operations.clear
    @stack_rpn.clear

    tokens = if expression.is_a?(Array)
               expression
             else
               RuleEvaluator.tokenize(clause: expression)
             end

    # /* loop for handling each token - shunting-yard algorithm */
    tokens.each { |token| shunt_internal(token: token) }

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
  def evaluate(scenario: [])
    if @stack_rpn.size == 1
      evaluate_one_rpn(scenario: scenario).to_s
    else
      evaluate_multi_rpn(
        scenario: scenario,
        rule_token_convert: @token_converters
      )
    end
  end

  # /**
  #  * @param rule_token_convert token to converter map.
  #  * @param default_converter default converter to use.
  #  */
  def next_value(rule_token_convert: {})
    token = @stack_answer.pop
    default = {
      subscript: -1,
      value: token
    }

    return default if token.is_a?(Array) || [TRUE, FALSE].include?(token)

    next_value_default(token)
  end

  # private
  def next_value_default(token)
    token_cleaned = token.to_s.strip
    subscript = TokenUtil.extract_subscript(token: token_cleaned)
    token_body = subscript > -1 ? token_cleaned[/^.+(?=\[)/] : token_cleaned

    raise "Config Error: Outcome clause token: '#{token}' not found in variables" if @token_converters[token_body].nil?

    {
      value: @token_converters[token_body].convert(token_body),
      subscript: subscript
    }
  end

  # /** @param token token. */
  def shunt_internal(token: '')
    if open_bracket?(token: token)
      @stack_operations << token
    elsif close_bracket?(token: token)
      shunt_close
    elsif operator?(token: token)
      shunt_operator(token)
    else
      @stack_rpn << token
    end
  end

  def shunt_operator(token)
    while !@stack_operations.empty? &&
          operator?(token: @stack_operations.last.strip) &&
          precedence(symbol_char: token[0]) <=
          precedence(symbol_char: @stack_operations.last.strip[0])
      @stack_rpn << @stack_operations.pop
    end
    @stack_operations << token
  end

  def shunt_close
    while @stack_operations.any? &&
          !open_bracket?(token: @stack_operations.last.strip)
      @stack_rpn << @stack_operations.pop
    end
    @stack_operations.pop
  end

  private

  # /**
  #  * @param scenario List of values to evaluate against the rule expression.
  #  * @param rule_token_convert token to converter map.
  #  */
  def evaluate_multi_rpn(scenario: [], rule_token_convert: {})
    # /* clean answer stack */
    @stack_answer.clear

    # /* get the clone of the RPN stack for further evaluating */
    stack_rpn_clone = Marshal.load(Marshal.dump(@stack_rpn))
    evaluate_stack_rpn(stack_rpn_clone, scenario, rule_token_convert)

    raise 'Some operator is missing' if @stack_answer.size > 1

    last = @stack_answer.pop
    last[1..last.size]
  end

  # evaluating the RPN expression
  def evaluate_stack_rpn(stack_rpn, scenario, rule_token_convert)
    while stack_rpn.any?
      token = stack_rpn.pop
      if operator?(token: token)
        evaluate_operator(scenario, rule_token_convert, token)
      else
        @stack_answer << token
      end
    end
  end

  def evaluate_operator(scenario, rule_token_convert, token)
    if NOT.symbol == token
      evaluate_multi_not(scenario: scenario)
    else
      evaluate_multi(
        scenario: scenario,
        rule_token_convert: rule_token_convert,
        operator: RuleEvaluator.operator_from_symbol(symbol: token[0])
      )
    end
  end

  # /**
  #  * @param scenario List of values to evaluate against the rule expression.
  #  * @param rule_token_convert token to converter map.
  #  * @param operator OR/AND.
  #  */
  def evaluate_multi(scenario: [], rule_token_convert: {}, operator: nil)
    # Convert 'nil' to nil.
    formatted_scenario = scenario.map { |token| token == 'nil' ? nil : token }

    left = next_value(rule_token_convert: rule_token_convert)
    right = next_value(rule_token_convert: rule_token_convert)

    answer = send(
      :perform_logical,
      scenario: formatted_scenario,
      left: left,
      right: right,
      operation: operator.name.to_sym
    )

    @stack_answer << format_internal_result(answer)
  end

  # /**
  #  * @param scenario List of values to evaluate against the rule expression.
  #  */
  def evaluate_multi_not(scenario: [])
    latest = @stack_answer.pop.strip

    answer = if LogicHelper::TRUE == latest
               LogicHelper::FALSE
             elsif LogicHelper::FALSE == latest
               LogicHelper::TRUE
             else
               evaluate_non_internal(scenario, latest)
             end

    @stack_answer << format_internal_result(answer)
  end

  def evaluate_non_internal(scenario, latest)
    subscript = TokenUtil.extract_subscript(token: latest)
    converter = DEFAULT_CONVERT_HASH[scenario.first.class]
    if subscript < 0
      converted = converter.convert(latest)
      (!scenario.include?(converted)).to_s
    else
      converted = converter.convert(latest[RE_TOKEN_BODY])
      (scenario[subscript] != converted).to_s
    end
  end

  # returns true if answer starts with *, *true if answer is true, same goes for
  # false.
  def format_internal_result(answer)
    if answer[0] == '*'
      answer
    else
      "*#{answer}"
    end
  end

  # /** @param scenario to evaluate against the rule expression. */
  def evaluate_one_rpn(scenario: [])
    single = @stack_rpn.last
    subscript = TokenUtil.extract_subscript(token: single)
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
