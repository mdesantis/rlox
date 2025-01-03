# frozen_string_literal: true

class RLox
  class Stmt
    class Block < Stmt
      attr_reader :statements

      def initialize(statements)
        @statements = statements
      end

      def accept(visitor)
        visitor.visit_block_stmt self
      end
    end
  end
end
