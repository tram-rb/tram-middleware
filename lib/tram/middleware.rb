require "dry/inflector"
require "dry-initializer"

# Namespace shared by tram projects
# @see https://github.com/tram-rb
module Tram
  #
  # @abstract
  # Configurable Middleware
  #
  class Middleware
    require_relative "middleware/input"
    require_relative "middleware/layer"
    require_relative "middleware/output"
    require_relative "middleware/stack_layer"
  end
end
