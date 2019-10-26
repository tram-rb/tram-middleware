class Tram::Middleware
  #
  # @private
  # The contract to filter data going forth through a middleware
  #
  class Output
    extend Dry::Initializer

    param :result

    class << self
      def call(result)
        new(result).result
      end

      # Human-readable description of the output contract
      # @return [String]
      def inspect
        desc = dry_initializer.params.first.desc || "A resulting value"
        "Output: #{desc}\n"
      end
    end
  end
end
