# frozen_string_literal: true

class RLox
  class Expr
    class Get < Expr
      attr_reader :object, :name

      def initialize(object, name)
        @object = object
        @name = name
      end

      def accept(visitor)
        visitor.visit_get_expr self
      end
    end
  end
end
