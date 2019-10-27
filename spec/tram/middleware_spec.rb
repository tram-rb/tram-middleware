RSpec.describe Tram::Middleware do
  before do
    class Test::Add < Tram::Middleware::Layer
      desc "Add number to a value"

      option :number, proc(&:to_i), desc: "Number to be added"
      option :value,  proc(&:to_i), desc: "Source value"

      def call
        yield(**options, value: value + number)
      end
    end

    class Test::Multiply < Tram::Middleware::Layer
      desc "Multiply a value by a number"

      option :number, proc(&:to_i), desc: "Number to multiply by"
      option :value,  proc(&:to_i), desc: "Source value"

      def call
        yield(**options, value: value * number)
      end
    end

    class Test::Return < Tram::Middleware::Layer
      desc "Return a source value"

      option :value, proc(&:to_i), desc: "Value to return"

      def call
        value
      end
    end
  end

  let(:middleware) do
    described_class.new do
      desc "Make some computations"

      # Ensure the input value is less than 10
      option :value, ->(i) { i.to_i % 10 }, desc: "Source value below 10"
      # Stringify the result
      output proc(&:to_s), desc: "The computation result"

      use Test::Add do |options|
        options[:number] = 1
      end

      use Test::Add, as: :add_three do |options|
        options[:number] = 3
      end

      use Test::Return

      use Test::Multiply, before: :add_three do |options|
        options[:number] = 2
      end
    end
  end

  describe ".use" do
    subject { middleware.use Test::Add, **params }

    context "with an acceptable params" do
      let(:params) { { as: :add_five } }

      it "doesn't raise" do
        expect { subject }.not_to raise_error
      end
    end

    context "when a value of :before option refers to absent layer" do
      let(:params) { { as: :add_five, before: :add_seven } }

      it "raises an error" do
        expect { subject }
          .to raise_error Tram::Middleware::LayerNotFoundError, /'add_seven'/
      end
    end

    context "when an explicit name of the layer is already taken" do
      let(:params) { { as: :add_three } }

      it "raises an error" do
        expect { subject }
          .to raise_error Tram::Middleware::LayerNotUniqueError, /'add_three'/
      end
    end

    context "when an implicit name of the layer is already taken" do
      let(:params) { {} }

      it "raises an error" do
        expect { subject }
          .to raise_error Tram::Middleware::LayerNotUniqueError, /'Test::Add'/
      end
    end
  end

  describe "#call" do
    subject { middleware.call value: "7" }

    # 7
    #   (7 % 10) + 1 = 8
    #     (8 % 10) * 2 = 16
    #        (16 % 10) + 3 = 9
    #           9.to_s
    it { is_expected.to eq "9" }

    context "when the stack is empty" do
      let(:middleware) do
        described_class.new do
          desc "Make some computations"

          option :value, ->(i) { i.to_i % 10 }, desc: "Source value below 10"
          output proc(&:to_s), desc: "The computation result"
        end
      end

      it "raises an error" do
        expect { subject }
          .to raise_error Tram::Middleware::EmptyStackError
      end
    end
  end

  describe "#inspect" do
    subject { middleware.inspect }

    it "returns a human-readable description" do
      expect(subject).to eq <<~INSPECT
        Tram::Middleware: Make some computations
          Input options:
            value: Source value below 10 (required)
          Stack layers:
            Test::Add: Add number to a value
              number: 1 (Number to be added)
            Test::Multiply: Multiply a value by a number
              number: 2 (Number to multiply by)
            add_three: Add number to a value
              number: 3 (Number to be added)
            Test::Return: Return a source value
          Output: The computation result
      INSPECT
    end
  end
end
