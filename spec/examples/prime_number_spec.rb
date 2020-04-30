# frozen_string_literal: true

require './lib/rast'
require './examples/prime_number'

rast PrimeNumber do
  spec '#prime?' do
    execute do |number|
      begin
        subject.prime?(number)
      rescue StandardError
        :ERROR
      end
    end
  end
end
