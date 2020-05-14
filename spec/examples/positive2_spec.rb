# frozen_string_literal: true

require './lib/rast'
require './examples/positive2'

rast Positive2 do
  xspec 'dummy' do
  end

  spec '#positive?' do
    execute do |number|
      begin
        subject.positive?(number)
      rescue RuntimeError
        :ERROR
      end
    end
  end
end
