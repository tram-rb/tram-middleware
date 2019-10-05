require "bundler/setup"
require "rspec/its"
require "pry"
require "tram/middleware"

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = :random
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # Prepare the Test namespace for constants defined in specs
  config.before(:each) { Test = Class.new(Module) }
  config.after(:each)  { Object.send :remove_const, :Test }
end
