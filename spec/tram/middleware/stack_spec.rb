RSpec.describe Tram::Middleware::Stack do
  # Input contract ensures a value is within [0..3]
  let(:input) { proc { |value:, **| { value: value % 4 } } }
  # Output contract ensures a value is a string
  let(:output) { proc(&:to_s) }
  # At the bottom we just return a value
  let(:floor) { proc { |value:| value } }
  # At the top we increase a filtered value by 2
  let(:ceil) { proc { |value:, &block| block.call(value: value + 2) } }

  # Construct a stack for the bottom layer only with some contracts
  let(:tail) { described_class.new head: floor, input: input, output: output }
  # Place a ceil layer on top of the tail with the same contracts
  let(:full) { described_class.new head: ceil, tail: tail }

  describe "#call" do
    subject { stack.call value: 7 }

    context "with a bottom layer" do
      let(:stack) { tail }

      it { is_expected.to eq "3" } # (7 % 4).to_s
    end

    context "with a top layer" do
      let(:stack) { full }

      it { is_expected.to eq "1" } # (((7 % 4) + 2) % 4).to_s
    end
  end

  describe ".build" do
    subject { described_class.build(input, output, ceil, floor) }

    it "builds a full stack" do
      expect(subject).to be_kind_of described_class
      result = subject.call(value: 7)

      expect(result).to eq "1"
    end
  end
end
