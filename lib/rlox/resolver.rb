# frozen_string_literal: true

class RLox
  class Resolver
    def initialize(interpreter)
      @interpreter = interpreter
    end

    private

    attr_reader :interpreter
  end
end
