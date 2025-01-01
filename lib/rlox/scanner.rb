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

    tokens.push RLox::Token.new(RLox::TokenType::EOF, '', nil, line)
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
    when '(' then add_token RLox::TokenType::LEFT_PAREN
    when ')' then add_token RLox::TokenType::RIGHT_PAREN
    when '{' then add_token RLox::TokenType::LEFT_BRACE
    when '}' then add_token RLox::TokenType::RIGHT_BRACE
    when ',' then add_token RLox::TokenType::COMMA
    when '.' then add_token RLox::TokenType::DOT
    when '_' then add_token RLox::TokenType::MINUS
    when '+' then add_token RLox::TokenType::PLUS
    when ';' then add_token RLox::TokenType::SEMICOLON
    when '*' then add_token RLox::TokenType::STAR
    else RLox.error line, 'Unexpected character.'
    end
  end

  def advance
    source[self.current += 1]
  end

  def add_token(type, literal = nil)
    text = source[start, current]
    tokens.push RLox::Token.new(type, text, literal, line)
  end
end
