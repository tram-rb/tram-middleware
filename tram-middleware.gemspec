Gem::Specification.new do |gem|
  gem.name     = "tram-middleware"
  gem.version  = "0.0.1"
  gem.author   = "Andrew Kozin (nepalez)"
  gem.email    = "andrew.kozin@gmail.com"
  gem.homepage = "https://github.com/tram-rb/tram-middleware"
  gem.summary  = "Simple DSL for building configurable middleware"
  gem.license  = "MIT"

  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = Dir["README.md", "LICENSE", "CHANGELOG.md"]

  gem.required_ruby_version = "> 2.3"

  gem.add_dependency "dry-inflector", "~> 0.1.2"
  gem.add_dependency "dry-initializer", "~> 3.0"

  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "rspec-its", "~> 1.3"
  gem.add_development_dependency "rake", "> 10.0"
  gem.add_development_dependency "inch", "~> 0.8.0"
  gem.add_development_dependency "rubocop", "~> 0.49"
end
