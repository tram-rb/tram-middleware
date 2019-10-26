RSpec.describe Tram::Middleware::Input do
  let(:input) { Class.new(described_class) }

  before do
    input.option :foo, proc(&:to_s), desc: "Some foo"
    input.option :bar, proc(&:to_i), desc: "Some bar"
  end

  describe ".call" do
    subject { input.call options }

    context "without missed options" do
      let(:options) { { foo: 1, bar: "3" } }

      it "coerces options" do
        expect(subject).to eq foo: "1", bar: 3
      end
    end

    context "with excessive options" do
      let(:options) { { foo: "1", bar: 3, baz: 5 } }

      it "removes undeclared options" do
        expect(subject).to eq options.slice(:foo, :bar)
      end
    end

    context "when some options are missed" do
      let(:options) { { foo: 1 } }

      it "raises StandardError" do
        expect { subject }.to raise_error StandardError
      end
    end
  end

  describe ".inspect" do
    subject { input.inspect }

    it "builds human-readable description" do
      expect(subject).to eq <<~TEXT
        Input options:
          foo: Some foo (required)
          bar: Some bar (required)
      TEXT
    end
  end
end
