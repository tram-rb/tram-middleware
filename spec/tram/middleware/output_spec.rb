RSpec.describe Tram::Middleware::Output do
  let(:output) { Class.new(described_class) }

  before { output.param :result, proc(&:to_s) }

  describe ".call" do
    subject { output.call(3) }

    it "coerces the argument" do
      expect(subject).to eq "3"
    end
  end
end
