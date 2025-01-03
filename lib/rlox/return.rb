# frozen_string_literal: true

class RLox
  class Return < ::RuntimeError
    attr_reader :value

    def initialize(value)
      super nil
      @value = value
    end
  end
end
