# frozen_string_literal: true

require './lib/rast'
require './examples/triple'

rast Triple do
  spec '#triple' do
    execute { |one, two, three| subject.triple(one, two, three) }
  end
end
