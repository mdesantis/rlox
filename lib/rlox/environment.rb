# frozen_string_literal: true

class RLox
  class Environment
    def initialize
      @values = {}
    end

    def define(name, value)
      values[name] = value
    end

    def get(name)
      values.fetch name.lexeme
    rescue KeyError
      raise RLox::RuntimeError.new name, "Undefined variable '#{name.lexeme}'."
    end

    private

    attr_accessor :values
  end
end
