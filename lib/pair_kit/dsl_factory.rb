module PairKit
  class DslFactory
    require_relative 'dsl_factory/version'
    require_relative 'dsl_factory/builder'
    require_relative 'dsl_factory/wrapper'

    attr_reader :builders, :default_builder

    def initialize(&block)
      @builders = {}
      instance_exec(&block) if block
    end

    def configure_builder(name, &block)
      (@builders[name.to_sym] ||= Class.new(Builder)).class_exec(&block)
      @default_builder = @builders.keys.first if @builders.size == 1
      self
    end

    def build(thing, builder_name = nil, **options, &block)
      builder_name = builder_name&.to_sym || @default_builder
      builder_class = builders[builder_name] || raise("Unknown builder #{builder_name}")

      Wrapper.new(builder_name, builder_class.new(self, thing, **options))
             .tap { |x| x.instance_exec(&block) if block }
    end

    def branch(&block)
      self.class.new
          .tap { |x| builders.each { |k, v| x.builders[k] = Class.new(v) } }
          .tap { |x| x.default_builder = default_builder }
          .tap { |x| x.instance_exec(&block) if block }

    end

    protected

    attr_writer :default_builder
  end
end
