# frozen_string_literal: true

class RLox
  class Stmt
    class Class < Stmt
      attr_reader :name, :methods

      def initialize(name, methods)
        @name = name
        @methods = methods
      end

      def accept(visitor)
        visitor.visit_class_stmt self
      end
    end
  end
end
