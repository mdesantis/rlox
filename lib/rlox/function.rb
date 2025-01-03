# frozen_string_literal: true

class RLox
  class Function
    def initialize(declaration)
      @declaration = declaration
    end

    def callable?
      true
    end

    def call(interpreter, arguments)
      environment = Environment.new interpreter.globals
      declaration.params.size.times do |i|
        environment.define declaration.params[i].lexeme, arguments[i]
      end

      interpreter.execute_block declaration.body, environment
      nil
    end

    def arity
      declaration.params.size
    end

    def to_s
      "<fn #{declaration.name.lexeme}>"
    end

    private

    attr_reader :declaration
  end
end
