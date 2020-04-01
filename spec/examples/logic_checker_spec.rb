# frozen_string_literal: true

require './lib/rast_dsl'
require './examples/logic_checker'

rast LogicChecker do
  prepare do |param1, param2|
    set(0, param1)
    set(1, param2)
  end

  execute do
    result(subject.and(get(0), get(1)))
  end
end
