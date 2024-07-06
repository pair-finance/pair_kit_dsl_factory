module PairKit
  class DslFactory
    require_relative 'dsl_factory/version'
    require_relative 'dsl_factory/builder'
    require_relative 'dsl_factory/wrapper'
    require_relative 'dsl_factory/context_dsl'

    attr_reader :builders

    def initialize(&block)
      @builders = {}
      instance_exec(&block) if block
    end

    def configure_builder(name, *modules, &block)
      (@builders[name.to_sym] ||= Class.new(Builder))
        .tap { |builder| modules.flatten.each { |mod| builder.class_exec { include mod }}}
        .tap { |builder| builder.class_exec(&block) if block }

      @default_builder = @builders.keys.first if @builders.size == 1
      self
    end

    def build(thing, context = nil, **options, &block)
      ContextDsl.new(self, context).call(thing, **options, &block)
      thing
    end

    def default_builder
      builders.keys.first
    end

    def branch(&block)
      self.class.new
          .tap { |x| builders.each { |k, v| x.builders[k] = Class.new(v) } }
          .tap { |x| x.instance_exec(&block) if block }
    end

    protected

    attr_writer :default_builder
  end
end
