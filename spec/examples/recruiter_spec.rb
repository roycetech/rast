# frozen_string_literal: true

require './lib/rast_dsl'
require './examples/recruiter'

rast Recruiter do
  spec '#assess' do
    prepare do |position, score|
      allow(subject).to receive(:score) { score }
      allow(subject).to receive(:position) { position }
    end

    execute do
      result subject.assess
    end
  end
end
