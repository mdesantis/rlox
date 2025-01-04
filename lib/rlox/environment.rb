# frozen_string_literal: true

class RLox
  class Environment
    def initialize(enclosing = nil)
      @values = {}
      @enclosing = enclosing
    end

    def define(name, value)
      values[name] = value
    end

    def get(name)
      return values[name.lexeme] if values.key? name.lexeme
      return enclosing.get name if enclosing

      raise RLox::RuntimeError.new name, "Undefined variable '#{name.lexeme}'."
    end

    def get_at(distance, name)
      ancestor(distance).values[name]
    end

    def ancestor(distance)
      environment = self
      distance.times do
        environment = environment.enclosing
      end

      environemnt
    end

    def assign(name, value)
      if values.key? name.lexeme
        values[name.lexeme] = value
        return
      end

      if enclosing
        enclosing.assign name, value
        return
      end

      raise RLox::RuntimeError.new name, "Undefined variable '#{name.lexeme}'."
    end

    def assign_at(distance, name, value)
      ancestor(distance).values[name.lexeme] = value
    end

    private

    attr_reader :values, :enclosing
  end
end
