# frozen_string_literal: true

require './lib/rast'
require './examples/logic_four'

rast LogicFour do
  spec 'Four' do
    execute do |one, two, three, four|
      result subject.process(one, two, three, four)
    end
  end
end
