# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][changelog]
and this project adheres to [Semantic Versioning][semver].

## [0.0.1] - Not Published
This is a first public release (nepalez)

## [0.0.2] - To be released soon

### Added
- Support deletion of any layer from a preconfigured middleware (nepalez)

  ```ruby
  middleware = Tram::Middleware.build do
    use FirstLayer
    use SecondLayer
    use ThirdLayer
  end

  middleware.drop :SecondLayer
  ```

  With this option the middleware became fully extendable

[changelog]: http://keepachangelog.com/
[semver]: http://semver.org/
[0.0.1]: https://github.com/tram-rb/tram-middleware/releases/tag/v0.0.1
[0.0.2]: https://github.com/tram-rb/tram-middleware/compare/v0.0.1...v0.0.2
