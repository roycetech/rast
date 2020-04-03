# frozen_string_literal: true

require './lib/rast_dsl'
require './examples/logic_checker'

rast LogicChecker do
  execute do |param1, param2|
    result(subject.and(param1, param2))
  end
end
