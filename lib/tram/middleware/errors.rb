class Tram::Middleware
  # @abstract
  # Base class for the errors which refer to a specific stack
  class StackError < ::StandardError
    # @!attribute [r] stack
    # @return [Tram::Middleware::Stack] The stack where the error has occured
    attr_reader :stack

    private

    def initialize(stack, message, *args)
      @stack = stack
      super _squish(message), *args
    end

    def _squish(text)
      text.lines.map(&:strip).join(" ")
    end
  end

  # The exception to be risen when an empty middleware is used
  class EmptyStackError < StackError
    private def initialize(stack, *args)
      message ||= "The stack is empty. Add layers to the middleware."

      super(stack, message, *args)
    end
  end

  # The exception to be risen when bottom layer tries to yield <nothing>
  class BottomLayerError < StackError
    private def initialize(stack, *args)
      message ||= <<~MESSAGE
        The bottom of the stack is reached. There is no more layers to yield.
        Check the stack and ensure that its bottom layer doesn't yield.
      MESSAGE

      super(stack, message, *args)
    end
  end

  # The exception to be risen when the layer is added before
  # another one, which cannot be found in a stack
  class LayerNotFoundError < StackError
    private def initialize(stack, key, *args)
      message ||= <<~MESSAGE
        The layer cannot be found in the stack by the key '#{key}'.
        Check the stack and provide a proper value for the option :before.
      MESSAGE

      super(stack, message, *args)
    end
  end

  # The exception to be risen when a layer is added under a name
  # which has been already used by another layer
  class LayerNotUniqueError < StackError
    private def initialize(stack, layer, *args)
      message ||= <<~MESSAGE
        The layer '#{layer.name}' (#{layer.layer.name})
        is already added to the stack.
        Use the option :as to provide another name for the layer.
      MESSAGE

      super(stack, message, *args)
    end
  end

  # The exception to be risen when a layer is added to the stack
  # under the name reserved by the gem
  class LayerNameError < StandardError
    private

    def initialize(name, *args)
      message ||= <<~MESSAGE
        The name '#{name}' is used by the `tram-middleware` library.
        Use the option :as to provide another name for the layer.
      MESSAGE

      super _squish(message), *args
    end

    def _squish(text)
      text.lines.map(&:strip).join(" ")
    end
  end
end
