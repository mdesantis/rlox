# frozen_string_literal: true

class RLox
  class Instance
    attr_reader :klass, :fields

    def initialize(klass)
      @klass = klass
      @fields = {}
    end

    def get(name)
      return fields[name.lexeme] if fields.key? name.lexeme

      method = klass.find_method name.lexeme
      return method.bind self if method

      raise RLox::RuntimeError.new name, "Undefined property '#{name.lexeme}'."
    end

    def set(name, value)
      fields[name.lexeme] = value
    end

    def to_s
      "#{klass.name} instance"
    end
  end
end
