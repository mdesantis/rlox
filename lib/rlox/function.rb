# frozen_string_literal: true

class RLox
  class Function
    def initialize(declaration, closure)
      @declaration = declaration
      @closure = closure
    end

    def callable?
      true
    end

    def call(interpreter, arguments)
      environment = Environment.new closure
      declaration.params.size.times do |i|
        environment.define declaration.params[i].lexeme, arguments[i]
      end

      begin
        interpreter.execute_block declaration.body, environment
      rescue Return => error
        return error.value
      end

      nil
    end

    def arity
      declaration.params.size
    end

    def to_s
      "<fn #{declaration.name.lexeme}>"
    end

    private

    attr_reader :declaration, :closure
  end
end
