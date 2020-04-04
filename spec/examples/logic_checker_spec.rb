# frozen_string_literal: true

require './lib/rast_dsl'
require './examples/logic_checker'

rast LogicChecker, spec: 'Logical AND' do
  execute do |param1, param2|
    result(subject.and(param1, param2))
  end
end

rast LogicChecker, spec: 'Logical OR' do
  execute do |param1, param2|
    result(subject.or(param1, param2))
  end
end
