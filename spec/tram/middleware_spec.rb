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

  describe "#call" do
    subject { middleware.call value: "7" }

    # 7
    #   (7 % 10) + 1 = 8
    #     (8 % 10) * 2 = 16
    #        (16 % 10) + 3 = 9
    #           9.to_s
    it { is_expected.to eq "9" }
  end
end
