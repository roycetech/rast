# frozen_string_literal: true

require './lib/rast/spec_dsl'

describe SpecDSL do
  describe '#execute' do
    it 'can detect bad configuration resulting in no outcome' do
      dummy_fixtures = [{ expected_outcome: nil}]

      sut = described_class.new(
        subject: '',
        name: '',
        fixtures: dummy_fixtures
      ) {}

      allow(sut).to receive(:generate_rspecs)

      expect { sut.execute{} }.to raise_error
    end
  end
end
