# frozen_string_literal: true

class RLox
  class Stmt
    class Return < Stmt
      attr_reader :keyword, :value

      def initialize(keyword, value)
        @keyword = keyword
        @value = value
      end

      def accept(visitor)
        visitor.visit_return_stmt self
      end
    end
  end
end
