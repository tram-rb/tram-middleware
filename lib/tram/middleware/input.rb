class Tram::Middleware
  #
  # @private
  # The contract to filter data going forth through a middleware
  #
  class Input
    extend Dry::Initializer

    class << self
      undef_method :param

      def call(**options)
        dry_initializer.attributes new(options)
      end
    end
  end
end
