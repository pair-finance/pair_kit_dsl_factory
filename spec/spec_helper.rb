# frozen_string_literal: true

# require 'debug/start'
require 'simplecov'

SimpleCov.start do
  add_filter 'spec/'
  add_filter '.github/'
  add_filter 'lib/pair_kit/dsl_factory/version'
end

if ENV['CI'] == 'true'
  require 'simplecov-cobertura'
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

require 'pry-byebug'
require 'pry-alias'

require 'pair_kit/dsl_factory'
