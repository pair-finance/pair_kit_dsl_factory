module PairKit
  class DslFactory
    class Builder
      def initialize(factory, subject, **options)
        @factory = factory
        @subject = subject
        @options = options
      end

      private

      attr_accessor :subject, :factory, :options

      def build(builder_name, new_thing, **options, &block)
        factory.build(builder_name, new_thing, **options, &block)
      end
    end
  end
end
