# frozen_string_literal: true

require './lib/rast'
require './examples/triple'

rast Triple do
  spec '#triple' do
    execute do |one, two, three|
      result subject.triple(one, two, three)
    end
  end
end
