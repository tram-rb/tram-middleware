RSpec.describe Tram::Middleware::Output do
  let(:output) { Class.new(described_class) }

  before { output.param :result, proc(&:to_s) }

  describe ".call" do
    subject { output.call(3) }

    it "coerces the argument" do
      expect(subject).to eq "3"
    end
  end

  describe ".inspect" do
    subject { output.inspect }

    it "returns a human-readable description" do
      expect(subject).to eq "Output: A resulting value\n"
    end
  end
end
