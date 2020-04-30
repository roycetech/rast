# frozen_string_literal: true

require './lib/rast'
require './examples/arithmetic_module'

rast ArithmeticModule do
  spec 'addition' do
    execute { |left, right| subject.add(left, right) }
  end
end
