# frozen_string_literal: true

class RLox
  class Stmt
    class Function < Stmt
      attr_reader :name, :params, :body

      def initialize(name, params, body)
        @name = name
        @params = params
        @body = body
      end

      def accept(visitor)
        visitor.visit_function_stmt self
      end
    end
  end
end
