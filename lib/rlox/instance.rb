# frozen_string_literal: true

class RLox
  class Instance
    attr_reader :klass

    def initialize(klass)
      @klass = klass
    end

    def to_s
      "#{klass.name} instance"
    end
  end
end
