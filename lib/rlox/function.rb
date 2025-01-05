# frozen_string_literal: true

class RLox
  class Function
    def initialize(declaration, closure, is_initializer)
      @declaration = declaration
      @closure = closure
      @is_initializer = is_initializer
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

      return closure.get_at 0, 'this' if initializer?

      nil
    end

    def bind(instance)
      environment = Environment.new closure
      environment.define 'this', instance
      self.class.new declaration, environment, initializer?
    end

    def arity
      declaration.params.size
    end

    def to_s
      "<fn #{declaration.name.lexeme}>"
    end

    def initializer?
      @is_initializer
    end

    private

    attr_reader :declaration, :closure
  end
end
