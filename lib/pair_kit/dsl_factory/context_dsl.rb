module PairKit
  class DslFactory
    class ContextDsl
      def initialize(dsl, context)
        @dsl = dsl
        @context = context
      end

      def call(thing, **options, &block)
        builder_name = (options[:builder] = options[:builder]&.to_sym || @dsl.default_builder)

        builder_class = @dsl.builders[builder_name] || raise("Unknown builder #{builder_name}")

        Wrapper.new(builder_name, builder_class.new(self, thing, @context, **options))
               .tap { |x| x.instance_exec(&block) if block }
      end
    end
  end
end
