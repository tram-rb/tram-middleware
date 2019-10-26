class Tram::Middleware
  #
  # @private
  # The contract to filter data going forth through a middleware
  #
  class Input
    extend Dry::Initializer

    class << self
      undef_method :param

      def option(*args, &block)
        @inspect = nil
        super
      end

      def call(**options)
        dry_initializer.attributes new(options)
      end

      # Human-readable description of the input contract
      # @return [String]
      def inspect
        @inspect ||= begin
          lines = dry_initializer.options.map do |item|
            text = "  #{item.target}"
            text << ": #{item.desc}" if item.desc
            text << " (required)" unless item.optional
            text
          end

          ["Input options:", *lines, nil].join("\n") if lines.any?
        end
      end
    end
  end
end
