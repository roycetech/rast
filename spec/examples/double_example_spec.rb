# frozen_string_literal: true

require './lib/rast'
require './examples/double_example'

rast DoubleExample do
  spec '#process' do
    prepare do |subject, with_sim, best|
      allow(subject).to receive(:sim) { double(best?: best) } if with_sim
    end

    execute do
      result subject.process
    end
  end
end
