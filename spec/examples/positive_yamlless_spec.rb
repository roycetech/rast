# frozen_string_literal: true

require './lib/rast'
require './examples/positive'

rast Positive do
  spec '#positive?' do
    variables({ number: [-1, 0, 1, 2, 3] })
    outcomes(true: 1)
    inclusion('!3')
    exclusion(2)
    default(:false) # optional
    execute { |number| subject.positive?(number) }
  end
end
