require './lib/rast'
require './lib/rast/rules/rule_evaluator'

rast RuleEvaluator do
  spec '.tokenize' do
    execute do |param|
      RuleEvaluator.tokenize(clause: param)
    end
  end

  spec '#evaluate_multi_not' do
    execute do |scenario, last_answer, subscript|

      top = last_answer.to_s
      top = "#{top}[#{subscript}]" if subscript > -1

      subject.instance_variable_set(:@stack_answer, [top])
      subject.send(:evaluate_multi_not, scenario: scenario).first
    end
  end
end
