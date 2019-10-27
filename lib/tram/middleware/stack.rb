class Tram::Middleware
  #
  # @private
  # The nested stack of pre-configured middleware layers
  #
  class Stack
    extend Dry::Initializer

    option :head # <Tram::Middleware::StackLayer>
    option :tail,   optional: true
    option :input,  default: -> { tail&.input }
    option :output, default: -> { tail&.output }

    # Call the stack of middleware
    # It validates input/output contracts, and yields the tail of the stack
    # @param  [Hash<Symbol, _>] params
    # @return [Object]
    def call(**params)
      params = input.call(**params) if input
      result = head.call(**params, &_yield)
      output ? output.call(result) : result
    end

    # Human-readable description of the stack
    # @return [String]
    def inspect
      @inspect ||= [head.inspect, tail&.inspect].compact.join
    end

    # @!method build(input, output, *layers)
    # Build the stack from layers ordered from top to bottom
    # @param [#call] input Input contract
    # @param [#call] output Output contract
    # @param [*Array<#call>] layers Ordered layers of the stack
    # @return [Tram::Middleware::Stack]
    def self.build(input, output, *layers, bottom)
      stack = new(head: bottom, input: input, output: output)
      layers.reverse.reduce(stack) { |tail, head| new(head: head, tail: tail) }
    end

    private

    def _yield
      @_yield ||= \
        if tail
          proc { |**params| tail.call(**params) }
        else
          proc { |**| raise BottomLayerError, self }
        end
    end
  end
end
