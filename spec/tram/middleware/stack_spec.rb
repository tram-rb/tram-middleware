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

  describe "#inspect" do
    subject { stack.inspect }

    before do
      class Test::Ceil < Tram::Middleware::Layer
        desc "Adds number to a value"

        option :number, desc: "The number to be added"
        option :value,  desc: "The source value"
      end

      class Test::Floor < Tram::Middleware::Layer
        desc "Returns a value"
      end
    end

    let(:stack) { described_class.build(input, output, ceil, floor) }

    let(:ceil) do
      filter = proc { |opts| opts[:number] = 2 }
      Tram::Middleware::StackLayer.new(:ceil, Test::Ceil, filter)
    end

    let(:floor) { Tram::Middleware::StackLayer.new(:floor, Test::Floor) }

    it "returns a human-readable description" do
      expect(subject).to eq <<~INSPECT
        ceil: Adds number to a value
          number: 2 (The number to be added)
        floor: Returns a value
      INSPECT
    end
  end
end
