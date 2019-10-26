class Tram::Middleware
  #
  # @abstract
  # Base class for configurable layers of a middleware stack
  #
  class Layer
    extend Dry::Initializer

    # @!attribute [r] options
    # @return [Hash<Symbol, Object>] the data received by the layer
    option :options

    # @absract
    # Handle the layer
    # @yield [Proc] The block with the rest of the middleware
    # @yieldparam [Hash<Symbol, Object>] The data for the bottom layers
    # @return [Object] The output of the layer
    def call
      raise NotImplementedError
    end

    # @private
    RESERVED_NAMES = [*instance_methods, *private_instance_methods].freeze
    # @private
    UNDEFINED = Object.new.freeze

    class << self
      undef_method :param

      # Get or set a human-readable description of the layer
      # @param  [#to_s] text
      # @return [String]
      def desc(text = UNDEFINED)
        @desc = text.to_s unless text == UNDEFINED
        @desc
      end

      # @!method option(name, coercer = nil, **options)
      # Add a configurable attribute of the layer
      # @param  [#to_s] name The mandatory option name
      # @param  [#call] coercer (nil) An optional value coercer
      # @option [#call] :type (nil) Another means to set the coercer
      # @option [Object] :default (nil) A default value of the attribute
      # @option [Boolean] :optional (false) If the option can be skipped
      # @option [#to_s] :desc (nil) Human-readable description of the option
      # @yield The block (an alternative way to describe the attribute)
      # @return [self]
      def option(name, *args, **opts, &block)
        _check!(name)
        opts = opts.slice(:type, :desc, :default, :optional)
        _mutate { super(name, *args, **opts, &block) }
      end

      # @!method call(options, &block)
      # Calls the layer
      # @param [Hash<Symbol, Object>] options The data to process
      # @yield The block with the rest of the stack
      # @yieldparam [Hash<Symbol, Object>] Processed options
      # @return [Object] The result of the processing
      def call(**options, &block)
        new(options).call(&block)
      end

      # Human-readable description of the layer
      # @return [String]
      def inspect
        @inspect ||= begin
          header = [name, desc].compact.join(": ")
          lines =
            dry_initializer
            .options
            .reject { |item| item.target == :options }
            .map { |item| ["  #{item.target}", item.desc].compact.join(": ") }

          [header, lines, nil].join("\n")
        end
      end

      private

      def _check!(name)
        return unless RESERVED_NAMES.include?(name.to_sym)

        raise "Choose another name for this option"
      end

      def _mutate
        @inspect = nil
        yield
        self
      end
    end
  end
end
