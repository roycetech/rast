# frozen_string_literal: true

require './lib/rast_dsl'
require './examples/logic_checker'

rast LogicChecker, spec: 'Logical AND' do
  execute do |left, right|
    result subject.and(left, right)
  end
end

rast LogicChecker, spec: 'Logical OR' do
  execute do |left, right|
    result(subject.or(left, right))
  end
end
