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

  def scan_token
    c = advance
    case c
    when '(' then add_token TokenType::LEFT_PAREN
    when ')' then add_token TokenType::RIGHT_PAREN
    when '{' then add_token TokenType::LEFT_BRACE
    when '}' then add_token TokenType::RIGHT_BRACE
    when ',' then add_token TokenType::COMMA
    when '.' then add_token TokenType::DOT
    when '_' then add_token TokenType::MINUS
    when '+' then add_token TokenType::PLUS
    when ';' then add_token TokenType::SEMICOLON
    when '*' then add_token TokenType::STAR
    end
  end

  def advance
    source[self.current += 1]
  end

  def add_token(type, literal = nil)
    text = source[start, current]
    tokens.push Token.new(type, text, literal, line)
  end
end
