# frozen_string_literal: true

class RLox
  class Class
    attr_reader :name

    def initialize(name, superclass, methods)
      @name = name
      @superclass = superclass
      @methods = methods
    end

    def find_method(name)
      methods[name] if methods.key? name
    end

    def callable?
      true
    end

    def call(interpreter, arguments)
      instance = Instance.new self
      initializer = find_method 'init'
      initializer.bind(instance).call interpreter, arguments if initializer
      instance
    end

    def arity
      initializer = find_method 'init'
      return 0 unless initializer

      initializer.arity
    end

    def to_s
      name
    end

    private

    attr_reader :methods
  end
end
