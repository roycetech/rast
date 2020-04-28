# frozen_string_literal: true

require './lib/rast'
require './examples/positive'

rast Positive do
  spec '#positive?' do
    execute do |number|
      result subject.positive?(number)
    end
  end
end
