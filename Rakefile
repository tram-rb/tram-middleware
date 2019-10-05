require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "inch/rake"

RSpec::Core::RakeTask.new(:spec)

begin
  RuboCop::RakeTask.new
rescue StandardError
  task :rubocop
end

begin
  Inch::Rake::Suggest.new(:inch, "--pedantic")
rescue StandardError
  task :inch
end

task default: %i[spec rubocop inch]
