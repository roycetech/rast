# frozen_string_literal: true

require './lib/rast_dsl'
require './examples/prime_number'

rast PrimeNumber do
  prepare do |param1|
    set(0, param1)
    set(1, param2)
  end

  execute do |number|
    result(subject.prime?(number))
  rescue x
    resut(:ERROR)
  end
end
