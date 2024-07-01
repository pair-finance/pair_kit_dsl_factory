module PairKit
  class DslFactory
    class Wrapper
      def initialize(name, builder)
        @name = name
        @builder = builder
      end

      def respond_to_missing?(method_name, include_private = false)
        @builder.respond_to?(method_name) || super
      end

      def method_missing(method_name, *args, **kw_args, &block)
        if @builder.respond_to?(method_name)
          builder_return = @builder.public_send(method_name, *args, **kw_args, &block)
          if block
            self
          else
            builder_return.is_a?(Wrapper) ? builder_return : self
          end
        else
          raise "Method missing #{method_name} for builder #{@name}"
        end
      end
    end
  end
end
