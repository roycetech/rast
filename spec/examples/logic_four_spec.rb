# frozen_string_literal: true

require './lib/rast'
require './examples/logic_four'

rast LogicFour do
  spec 'Four' do
    execute { |one, two, three, four| subject.process(one, two, three, four) }
  end
end
