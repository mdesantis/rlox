# frozen_string_literal: true

class RLox::Scanner
  def initialize(source)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line = 1
  end

  def scan_tokens
    until at_end?
      # We are at the beginning of the next lexeme.
      self.start = current
      scan_token
    end

    tokens.push Token.new(TokenType::EOF, '', nil, line)
    tokens
  end

  private

  attr_reader :source, :tokens
  attr_accessor :start, :current, :line

  def at_end?
    current >= source.size
  end
end
