# frozen_string_literal: true

require './examples/positive'

describe Positive do
  let(:number) {}

  subject { described_class.new.positive?(number) }

  context '#positive?' do

    it 'matches expected' do
      expect(described_class.new.positive?(-1)).to be_falsey
      expect(described_class.new.positive?(0)).to be_falsey
      expect(described_class.new.positive?(1)).to be_truthy
    end

    context 'given -1' do
      let(:number) { -1 }

      example { is_expected.to eq(false) }
    end

    context 'given 0' do
      let(:number) { 0 }

      example { is_expected.to eq(false) }
    end

    context 'given 1' do
      let(:number) { 1 }

      example { is_expected.to eq(true) }
    end
  end
end

describe Positive do
  {
    -1 => false,
    0 => false,
    1 => true
  }.each do |number, expected_outcome|
    example "#{expected_outcome} = #positive?(#{number})" do
      expect(subject.positive?(number)).to eq(expected_outcome)
    end
  end
end
