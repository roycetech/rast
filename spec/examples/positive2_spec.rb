# frozen_string_literal: true

require './lib/rast'
require './examples/positive2'

rast Positive2 do
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
