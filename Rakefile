require 'rake'
require 'debug'

begin
  require 'bundler/setup'
  Bundler::GemHelper.install_tasks
rescue LoadError
  puts 'although not required, bundler is recommended for running the tests'
end

task default: :spec

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-performance'
  task.requires << 'rubocop-rspec'
end
