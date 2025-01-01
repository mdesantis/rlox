# frozen_string_literal: true

class RLox
  class Scanner
    include TokenType

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

      tokens.push Token.new(EOF, '', nil, line)
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
      when '(' then add_token LEFT_PAREN
      when ')' then add_token RIGHT_PAREN
      when '{' then add_token LEFT_BRACE
      when '}' then add_token RIGHT_BRACE
      when ',' then add_token COMMA
      when '.' then add_token DOT
      when '_' then add_token MINUS
      when '+' then add_token PLUS
      when ';' then add_token SEMICOLON
      when '*' then add_token STAR
      when '!' then add_token match?('=') ? BANG_EQUAL : BANG
      when '=' then add_token match?('=') ? EQUAL_EQUAL : EQUAL
      when '<' then add_token match?('=') ? LESS_EQUAL : LESS
      when '>' then add_token match?('=') ? GREATER_EQUAL : GREATER
      else RLox.error line, 'Unexpected character.'
      end
    end

    def advance
      current = self.current
      self.current += 1
      source[current]
    end

    def add_token(type, literal = nil)
      text = source[start...current]
      tokens.push Token.new(type, text, literal, line)
    end

    def match?(expected)
      return false if at_end?
      return false if source[current] != expected

      self.current += 1
      true
    end
  end
end
