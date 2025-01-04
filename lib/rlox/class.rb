# frozen_string_literal: true

class RLox
  class Class
    attr_reader :name

    def initialize(name, methods)
      @name = name
      @methods = methods
    end

    def find_method(name)
      methods[name] if methods.key? name
    end

    def callable?
      true
    end

    def call(_interpeter, _arguments)
      Instance.new self
    end

    def arity
      0
    end

    def to_s
      name
    end

    private

    attr_reader :methods
  end
end
