# frozen_string_literal: true

class RLox
  class Scanner
    KEYWORDS = {
      'and' => TokenType::AND,
      'class' => TokenType::CLASS,
      'else' => TokenType::ELSE,
      'false' => TokenType::FALSE,
      'for' => TokenType::FOR,
      'fun' => TokenType::FUN,
      'if' => TokenType::IF,
      'nil' => TokenType::NIL,
      'or' => TokenType::OR,
      'print' => TokenType::PRINT,
      'return' => TokenType::RETURN,
      'super' => TokenType::SUPER,
      'this' => TokenType::THIS,
      'true' => TokenType::TRUE,
      'var' => TokenType::VAR,
      'while' => TokenType::WHILE
    }.freeze

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
      when '-' then add_token TokenType::MINUS
      when '+' then add_token TokenType::PLUS
      when ';' then add_token TokenType::SEMICOLON
      when '*' then add_token TokenType::STAR
      when '!' then add_token match?('=') ? TokenType::BANG_EQUAL : TokenType::BANG
      when '=' then add_token match?('=') ? TokenType::EQUAL_EQUAL : TokenType::EQUAL
      when '<' then add_token match?('=') ? TokenType::LESS_EQUAL : TokenType::LESS
      when '>' then add_token match?('=') ? TokenType::GREATER_EQUAL : TokenType::GREATER
      when '/'
        if match?('/')
          advance while peek != "\n" && !at_end? # Ignore comments.
        else
          add_token TokenType::SLASH
        end
      when ' ', "\r", "\t" # Ignore whitespace.
      when "\n" then self.line += 1
      when '"' then string
      when method(:digit?) then number
      when method(:alpha?) then identifier
      else RLox.error 'Unexpected character.', line: line
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
        RLox.error 'Unterminated string.', line: line
        return
      end

      # The closing ".
      advance

      # Trim the surrounding quotes.
      value = source[(start + 1)...(current - 1)]
      add_token TokenType::STRING, value
    end

    def digit?(char)
      char >= '0' && char <= '9'
    end

    def number
      advance while digit? peek

      # Look for a fractional part.
      if peek == '.' && digit?(peek_next)
        # Consume the "."
        advance

        advance while digit? peek
      end

      add_token TokenType::NUMBER, source[start...current].to_f
    end

    def peek_next
      return "\0" if (current + 1) >= source.size

      source[current + 1]
    end

    def identifier
      advance while alphanumeric? peek

      text = source[start...current]
      type = KEYWORDS[text] || TokenType::IDENTIFIER

      add_token type
    end

    def alpha?(char)
      (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z') || char == '_'
    end

    def alphanumeric?(char)
      alpha?(char) || digit?(char)
    end
  end
end
