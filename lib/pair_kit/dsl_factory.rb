module PairKit
  class DslFactory
    require_relative 'dsl_factory/version'
    require_relative 'dsl_factory/builder'
    require_relative 'dsl_factory/wrapper'

    attr_reader :builders

    def initialize(&block)
      @builders = {}
      instance_exec(&block) if block
    end

    def configure_builder(name, &block)
      (@builders[name.to_sym] ||= Class.new(Builder)).class_exec(&block)
      self
    end

    def build(builder_name, thing, **options, &block)
      builder_class = builders[builder_name.to_sym] || raise("Unknown builder #{builder_name}")

      Wrapper.new(builder_name, builder_class.new(self, thing, **options))
             .tap { |x| x.instance_exec(&block) if block }
    end

    def branch(&block)
      self.class.new
          .tap { |x| builders.each { |k, v| x.builders[k] = Class.new(v) } }
          .tap { |x| x.instance_exec(&block) if block }
    end
  end
end
