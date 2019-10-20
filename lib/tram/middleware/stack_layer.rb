class Tram::Middleware
  #
  # @private
  # The layer of the stack containing a pre-configured filter
  # to coerce source options.
  #
  class StackLayer
    extend Dry::Initializer

    param :name,   proc(&:to_s)
    param :layer,  reader: :private
    param :filter, reader: :private, optional: true

    def call(**options, &block)
      layer.call(**_coerce(options), options: options, &block)
    end

    private

    def _coerce(options)
      options = options.dup
      filter&.call(options)
      options
    end
  end
end
