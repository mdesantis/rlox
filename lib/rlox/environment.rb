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
      return values[name.lexeme] if values.key? name
      return enclosing.get name if enclosing

      raise RLox::RuntimeError.new name, "Undefined variable '#{name.lexeme}'."
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

    private

    attr_reader :values, :enclosing
  end
end
