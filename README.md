# [WIP] Tram::Middleware

Simple DSL for building configurable middleware

[![Gem Version][gem-badger]][gem]
[![Build Status][travis-badger]][travis]

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tram-middleware'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tram-middleware

## Example

Let's build a tiny translator that translates a text via Google Translate, but skips translation of texts, surrounded by double `##`.

We're going to provide the following API:

```ruby
translator.call text: "The ##Ruby## is awesome!", from: :en, into: :ru
# => "Ruby потрясающий!"
```

We will build it as a stack of 3 middleware:

- check if the translation is necessary
- transform texts surrounded by `##` into `<span class='notranslate'>...</span>`,
  and restore it back to the original chunk after translation
- send strings to the Google API via [GoogleTranslateDiff][google-translate-diff]

### The Design

Let's start from defining a translator.

```ruby
translator = Tram::Middleware.new do
  desc "Translate the text from one locale into another"

  # This is an input contract for every layer
  option :text, proc(&:to_s), desc: "The text to be translated"
  option :from, proc(&:to_s), desc: "The source locale"
  option :into, proc(&:to_s), desc: "The target locale"

  # This is an output contract
  output proc(&:to_s)

  # Build a stack in the natural order from outer to inner layers
  use CheckNecessity
  use SanitizeNotranslate, as: :sanitize
  use GoogleTranslate do |options|
    # Define one of the options, expected by this layer at a load time
    options[:api_key] = ENV["GOOGLE_API_KEY"]
  end
end
```

This allows to extend an already configured middleware

### Layers

Earlier we used some classes as a layers. Let's declare them (in fact, they must be defined first).

When defining a layer we should:
- provide the layer's description
- define options expected by the layer
- specify additional rules be satisfied by options

```ruby
class CheckNecessity < Tram::Middleware
  desc "Skip translation to the same language"

  # These are options used by a layer. All the rest of options are ignored
  option :text, desc: "The text to be translated"
  option :from, desc: "The source locale"
  option :into, desc: "The target locale"

  def call
    return text if from == into

    # Call the next layer and return its results
    # Through the options you can access all input, including
    # options that weren't declared by the layer, but
    # declared by a middleware
    yield(options)
  end
end
```

That was simple. The next layer uses a local state shared by handlers of input and output:

```ruby
class SanitizeNotranslate < Tram::Middleware
  desc "Prevent translation of texts inside double ##"

  # This is the only option this layer is interested in
  # Nethertheless, the `options` would also contain keys
  # `:from` and `:into` because they are declared by a middleware
  option :text, proc(&:to_s), desc: "The text to be sanitized"

  def call
    # Remember the local state which is necessary for the outtput
    input, state = prepare(text)

    # Call the next layer
    output = yield(**options, text: input)

    # Use the local state
    restore(output, state)
  end

  private

  # Extracts chunks wrapped in '##' like: 'The ##OS#2## system' -> 'OS#2'
  CHUNK = /##((?:#(?!#)|[^#])*)##/.freeze

  def prepare(text)
    state = text.scan(CHUNK).uniq
    input = state.with_index.reduce(text) do |text, (chunk, num)|
      text.gsub "###{chunk}##", "<span class='notranslate'>#{num}</span>"
    end

    [input, state]
  end

  def restore(text, state)
    state.with_index.reduce(text) do |text, (chunk, num)|
      text.gsub "<span class='notranslate'>#{num}</span>", chunk
    end
  end
end
```

In the innest layer we show how to add a configuration.

```ruby
class GoogleTranslate < Tram::Middleware
  desc "Send text for translation by GoogleTranslateDiff"

  # This option is not defined at the middleware layer,
  # and it wan't be included into the `#options` hash.
  # You should provide it when adding a layer in the method `use`
  option :api_key, proc(&:to_s), desc: "Google auth key"
  option :text,    proc(&:to_s), desc: "The text to be translated"

  def call
    # We don't yield here because this is the innest layer.
    # If we still yielded, this would raise NotImplementedError
    # because there's no more layers to call.
    client.translate(text, options.slice(:from, :into))
  end

  private

  # Use pre-configured `api_key`
  def client
    @client ||= GoogleTranlsateDiff.new(api_key: api_key)
  end
end
```

That's that. We defined both the stack and inter-layer interfaces, and can use the translator:

```ruby
translator = Tram::Middleware do
  # ...
end

translator.call text: "The ##Ruby## is awesome!", from: :en, into: :ja
# => "Rubyは素晴らしいです！"
```

### Inspection

With all the definitions above you can inspect the resulting middleware (that's what descriptions were for):

```text
> puts translator.inspect
Tram::Middleware: Translate text from one language into another
  Input options:
    text: The text to be translated (required)
    from: The source locale (required)
    into: The target locale (required)
  Stack layers:
    CheckNecessity: Skip translation to the same language
    sanitize: Prevent translation of texts inside double ##
    GoogleTranslate: Send text for translation by GoogleTranslateDiff
      api_key: "foobar" (The authentication key to the Google Translate API)
  Output: The translated text
=> nil
```

### Extencion of the Existing Stack

Before we composed the stack with the only method `use`, which appends layers to the bottom.

You can also extend the existing stack by adding a layer to the arbitrary place, and removing layers from a stack.

Suppose we have a stack:

```ruby
translator = Tram::Middleware.new do
  # ...
  use CheckNecessity
  use SanitizeNotranslate, as: :sanitize
  use GoogleTranslate do |options|
    # Define one of the options, expected by this layer at a load time
    options[:api_key] = ENV["GOOGLE_API_KEY"]
  end
end
```

Now we can modify it:

```ruby
translator.drop :sanitize
translator.use DoSomethingElse, before: :GoogleTranslate, as: :new_layer
```

Now the stack differs:

```text
> puts translator.inspect
Tram::Middleware: Trrnslate text from one language into another
  # ...
  Stack layers:
    CheckNecessity: Skip translation to the same language
    new_layer: Do something else
    GoogleTranslate: Send text for translation by GoogleTranslateDiff
      api_key: "foobar" (The authentication key to the Google Translate API)
```

That's how you can do your middleware extendable.


## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `bundle exec rake` to run the tests and linters.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tram-rb/tram-middleware.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[dry-initializer]: https://github.com/dry-rb/dry-initializer
[gem-badger]: https://img.shields.io/gem/v/tram-middleware.svg?style=flat
[gem]: https://rubygems.org/gems/tram-middleware
[travis-badger]: https://img.shields.io/travis/tram-rb/tram-middleware/master.svg?style=flat
[travis]: https://travis-ci.org/tram-rb/tram-middleware
