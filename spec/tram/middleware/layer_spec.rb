RSpec.describe Tram::Middleware::Layer do
  before do
    class Test::ModuloDivision < Tram::Middleware::Layer
      desc "Apply the app to the result of the modulo division"

      option :modulo, proc(&:to_i), desc: "The modulo"
      option :number, proc(&:to_i), desc: "The number to modify"

      def call
        div = number % modulo
        yield(div) + options[:nonce]
      end
    end
  end

  let(:layer) { Test::ModuloDivision }

  describe ".call" do
    subject { layer.call(params, &block) }

    let(:params) { { number: 14, modulo: 9, options: { nonce: 3 } } }
    let(:block)  { proc { |x| x * 2 } }

    it { is_expected.to eq 13 } # (14 % 9) * 2 + 3
  end

  describe ".option" do
    context "with a new option" do
      subject { layer.option :foo, optional: true }

      it "doesn't raise an exception" do
        expect { subject }.not_to raise_error
      end
    end

    context "with a reserved option" do
      subject { layer.option :options, optional: true }

      it "raises an exception" do
        expect { subject }.to raise_error StandardError
      end
    end
  end

  describe ".inspect" do
    subject { layer.inspect }

    it "builds human-readable description" do
      expect(subject).to eq <<~TEXT
        Test::ModuloDivision: Apply the app to the result of the modulo division
          modulo: The modulo
          number: The number to modify
      TEXT
    end
  end
end
