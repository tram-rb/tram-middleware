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

    # Human-readable description of the layer
    # @return [String]
    def inspect
      @inspect ||= begin
        header = [name, layer.desc].compact.join(": ")
        [header, *_inspect_options, nil].join("\n")
      end
    end

    private

    def _coerce(options)
      options = options.dup
      filter&.call(options)
      options
    end

    def _inspect_options
      config = {}.tap { |opts| filter&.call(opts) }

      list = layer.dry_initializer.options.select do |opt|
        config.keys.include?(opt.target)
      end

      list.map do |item|
        line = "  #{item.target}: #{config[item.target].inspect}"
        line << " (#{item.desc})" if item.desc
      end
    end
  end
end
