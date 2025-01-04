# frozen_string_literal: true

class RLox
  class Expr
    class Set < Expr
      attr_reader :object, :name, :value

      def initialize(object, name, value)
        @object = object
        @name = name
        @value = value
      end

      def accept(visitor)
        visitor.visit_set_expr self
      end
    end
  end
end
