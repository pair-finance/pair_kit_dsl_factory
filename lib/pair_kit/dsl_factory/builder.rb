module PairKit
  class DslFactory
    class Builder
      def initialize(dsl, subject, context, **options)
        @dsl = dsl
        @subject = subject
        @context = context
        @options = options
      end
    end
  end
end
