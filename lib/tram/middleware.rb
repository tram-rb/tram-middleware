require "dry/inflector"
require "dry-initializer"

# Namespace shared by tram projects
# @see https://github.com/tram-rb
module Tram
  #
  # @abstract
  # Configurable Middleware
  #
  # @example
  #   translator = Tram::Middleware.new do
  #     desc "Translate the string from one locale into another"
  #
  #     option :text, proc(&:to_s), desc: "The text to translate"
  #     option :from, proc(&:to_s), desc: "The source locale"
  #     option :into, proc(&:to_s), desc: "The target locale"
  #     output        proc(&:to_s), desc: "The result of the translation"
  #
  #     use CheckLocales do |options|
  #       options[:available_locales] = %w[en de fr it es ru ka]
  #     end
  #
  #     use DropHTML, as: :drop_html do |options|
  #       options[:preserve_tags] = %w[span]
  #     end
  #
  #     use GoogleTranslateDiff do |options|
  #       options[:api_key] = ENV["GoogleApiKey"]
  #     end
  #
  #     use PreventOverTranslation, before: :drop_html
  #   end
  #
  #   translator.call text: "The ##Ruby## is awesome!", from: :en, into: :ka
  #   # => "Ruby არის გასაოცარია!"
  #
  class Middleware
    require_relative "middleware/input"
    require_relative "middleware/layer"
    require_relative "middleware/output"
    require_relative "middleware/stack_layer"
    require_relative "middleware/stack"

    # Add the description of the middleware
    # @param [#to_s] text
    # @return [String]
    def desc(text)
      _mutate { @desc = text.to_s }
    end

    # @!method option(name, coercer = nil, **opts)
    # Add an option to the data that goes forth through the middleware
    # @param  [#to_s] name The name of the option
    # @param  [#call, Array<#call>] coercer The coercer of the option value
    # @option [#call, Array<#call>] :type Another way to define a coercer
    # @option [#call] :default The default value of the option
    # @option [Boolean] :optional (false) If the option is elective
    # @option [#to_s] :desc The description of the returned value
    # @yield definition for the nested data
    # @return [self]
    def option(*args, **opts, &block)
      _mutate { @input.option(*args, **opts, &block) }
    end

    # @!method output(coercer = nil, type: nil, description: nil)
    # Define a result that goes back through the middleware
    # @param  [#call, Array<#call>] coercer The coercer of value
    # @option [#call, Array<#call>] :type Another way to define a coercer
    # @option [#to_s] :desc The description of the returned value
    # @return [self]
    def output(*args, **opts)
      _mutate { @output.param(:result, *args, **opts) }
    end

    # Add a new layer to the bottom of the stack
    # @param [Class] klass The subclass of the [Tram::Middleware::Layer]
    # @option [#to_s] :as The unique name of the layer.
    #   It is equals the +klass+ name by default.
    #   Use this option to add more than one layer of the same type.
    # @option [#to_s] :before The name of the layer to be prepended by this one
    # @yield The block with a configuration of the layer
    # @yieldparam [Tram::Middleware::Layer] an instance of the +klass+
    # @return [self]
    def use(klass, as: nil, before: nil, &block)
      _mutate do
        name  = _unique!(as || klass)
        layer = StackLayer.new(name, klass, block)
        @layers.insert _index(before), layer
      end
    end

    # @!method call(options)
    # Call the middleware with some +options+ and return the result
    # @param [Hash<Symbol, _>] options
    #   Input options satisfying the restrictions of [#input]-s
    # @return [Object] the result satisfying the restrictions of [#output]
    def call(**options)
      stack.call(**options)
    end

    # Human-readable description of the middleware
    # @return [String]
    def inspect
      @inspect ||= nil
    end

    private

    def initialize(&block)
      @input  = Class.new(Input)
      @output = Class.new(Output)
      @layers = []
      instance_eval(&block)
    end

    def stack
      @stack ||= begin
        raise if @layers.empty?
        Stack.build(@input, @output, *@layers)
      end
    end

    def _mutate
      @stack = nil
      yield
      self
    end

    def _index(before = nil)
      return @layers.count unless before

      index = @layers.find_index { |l| l.name == before.to_s }
      return index if index

      raise
    end

    def _unique!(name)
      name = name.to_s
      existing_layer = @layers.any? { |layer| layer.name == name }
      return name unless existing_layer

      raise
    end
  end
end
