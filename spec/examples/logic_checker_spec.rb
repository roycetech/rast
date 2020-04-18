# frozen_string_literal: true

require './lib/rast'
require './examples/logic_checker'

rast LogicChecker do
  spec 'Logical AND' do
    execute do |left, right|
      result subject.and(left, right)
    end
  end

  spec 'Logical OR' do
    execute do |left, right|
      result subject.or(left, right)
    end
  end
end
