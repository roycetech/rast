# frozen_string_literal: true

require './lib/rast'
require './examples/positive'

rast Positive do
  spec '#positive?' do
    variables({number: [-1, 0, 1]})
    outcomes(true: 1)
    execute { |number| subject.positive?(number) }
  end
end
