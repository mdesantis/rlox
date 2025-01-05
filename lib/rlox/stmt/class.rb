# frozen_string_literal: true

class RLox
  class Stmt
    class Class < Stmt
      attr_reader :name, :superclass, :methods

      def initialize(name, superclass, methods)
        @name = name
        @superclass = superclass
        @methods = methods
      end

      def accept(visitor)
        visitor.visit_class_stmt self
      end
    end
  end
end
