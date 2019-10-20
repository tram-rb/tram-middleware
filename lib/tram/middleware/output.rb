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
    end
  end
end
