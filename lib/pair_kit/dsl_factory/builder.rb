module PairKit
  class DslFactory
    class Builder
      def initialize(dsl, subject, **options)
        @dsl = dsl
        @subject = subject
        @options = options
      end
    end
  end
end
