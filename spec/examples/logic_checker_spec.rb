# frozen_string_literal: true

require './lib/rast'
require './examples/logic_checker'

rast LogicChecker do
  spec 'Logical AND' do
    execute { |left, right| subject.and(left, right) }
  end

  spec 'Logical OR' do
    execute { |left, right| subject.or(left, right) }
  end

  spec 'Logical XOR' do
    execute { |left, right| subject.xor(left, right) }
  end
end
