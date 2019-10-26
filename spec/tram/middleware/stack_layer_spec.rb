RSpec.describe Tram::Middleware::StackLayer do
  let(:stack_layer) { described_class.new(name, layer, filter) }
  let(:name)   { :foo }
  let(:layer)  { proc(&:invert) }
  let(:filter) { proc { |opts| opts[:foo] = :FOO } }

  describe "#name" do
    subject { stack_layer.name }

    it "is stringified" do
      expect(subject).to eq name.to_s
    end
  end

  describe "#call" do
    subject { stack_layer.call bar: :BAZ }

    it "applies a filter to options sent to the layer" do
      expect(subject).to eq BAZ: :bar, FOO: :foo, { bar: :BAZ } => :options
    end
  end

  describe "#inspect" do
    subject { stack_layer.inspect }

    let(:layer) do
      Class.new(Tram::Middleware::Layer) do
        desc "Some layer"

        option :foo, desc: "Some foo"
        option :bar, desc: "Some bar"
      end
    end

    it "returns a human-readable description" do
      expect(subject).to eq <<~INSPECT
        foo: Some layer
          foo: :FOO (Some foo)
      INSPECT
    end
  end
end
