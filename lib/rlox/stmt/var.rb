# frozen_string_literal: true

class RLox
  class Stmt
    class Var < Stmt
      attr_reader :name, :initializer

      def initialize(name, initializer)
        @name = name
        @initializer = initializer
      end

      def accept(visitor)
        visitor.visit_var_stmt self
      end
    end
  end
end
