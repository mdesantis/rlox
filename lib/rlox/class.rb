# frozen_string_literal: true

class RLox
  class Class
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def to_s
      name
    end
  end
end
