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
  #     description "Translate the string from one locale into another"
  #
  #     input :text, proc(&:to_s), desc: "The text to translate"
  #     input :from, proc(&:to_s), desc: "The source locale"
  #     input :into, proc(&:to_s), desc: "The target locale"
  #     output       proc(&:to_s), desc: "The result of the translation"
  #
  #     use CheckLocales do |config|
  #       config.available_locales = %w[en de fr it es ru ka]
  #     end
  #
  #     use PreventOverTranslation
  #
  #     use DropHTML do |config|
  #       config.preserve_tags :span
  #     end
  #
  #     use GoogleTranslateDiff do
  #       config.api_key ENV["GoogleApiKey"]
  #     end
  #   end
  #
  #   translator.call text: "The ##Ruby## is awesome!", from: :en, into: :ka
  #   # => "Ruby არის გასაოცარია!"
  #
  class Middleware
  end
end
