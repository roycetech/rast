# frozen_string_literal: true

require './lib/rast'
require './examples/lohika'

rast Lohika do
  spec 'Lohika At' do
    execute { |kaliwa, kanan| subject.at(kaliwa, kanan) }
  end

  spec 'Lohika O' do
    execute { |kaliwa, kanan| subject.o(kaliwa, kanan) }
  end
end
