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
      when '/'
        if match?('/')
          advance while peek != "\n" && !at_end?
        else
          add_token SLASH
        end
      when ' ', "\r", "\t" # Ignore whitespace.
      when "\n" then self.line += 1
      when '"' then string
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

    def peek
      return "\0" if at_end?

      source[current]
    end

    def string
      while peek != '"' && !at_end?
        self.line += 1 if peek == "\n"
        advance
      end

      if at_end?
        RLox.error line, 'Unterminated string.'
        return
      end

      # The closing ".
      advance

      # Trim the surrounding quotes.
      value = source[(start + 1)...(current - 1)]
      add_token STRING, value
    end
  end
end
