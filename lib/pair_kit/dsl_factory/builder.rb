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

      def build(new_thing, **options, &block)
        factory.build(new_thing, **options, &block)
      end
    end
  end
end
