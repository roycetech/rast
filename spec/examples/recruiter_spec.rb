# frozen_string_literal: true

require './lib/rast'
require './examples/recruiter'

rast Recruiter do
  spec '#assess' do
    prepare do |position, score|
      allow(subject).to receive(:score) { score }
      allow(subject).to receive(:position) { position }
    end

    execute { subject.assess }
  end
end
