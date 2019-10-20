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
    require_relative "middleware/stack_layer"
  end
end
