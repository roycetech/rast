# frozen_string_literal: true

require './lib/rast'
require './examples/double_example'

rast DoubleExample do
  spec '#process' do
    prepare do |with_sim, best, with_product, product|
      allow(subject).to receive(:sim) { double(best?: best) } if with_sim

      if with_product
        allow(subject).to receive(:product) { double(key: product) }
      end
    end

    execute { subject.process ? 'AYG Best' : 'FALSE' }
  end
end
