# frozen_string_literal: true

class RLox
  class Parser
    def initialize(tokens)
      self.tokens = tokens
      self.current = 0
    end

    private

    attr_accessor :tokens, :current

    def expression
      equality
    end

    def equality
      expr = comparison

      while match TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL
        operator = previous
        right = comparison
        expr = Expr::Binary.new expr, operator, right
      end

      expr
    end

    def match(*types)
      types.each do
        if check type
          advance
          return true
        end
      end

      false
    end

    def check(type)
      return false if at_end?

      peek.type == type
    end

    def at_end?
      peek.type == EOF
    end

    def peek
      tokens[current]
    end

    def previous
      return if current.zero?

      tokens[current - 1]
    end

    def comparison
      expr = term

      while match TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL
        operator = previous
        right = term
        expr = Expr::Binary.new expr, operator, right
      end

      expr
    end

    def term
      expr = factor

      while match TokenType::MINUS, TokenType::PLUS
        operator = previous
        right = factor
        expr = Expr::Binary.new expr, operator, right
      end

      expr
    end

    def factor
      expr = unary

      while match TokenType::SLASH, TokenType::STAR
        operator = previous
        right = unary
        expr = Expr::Binary.new expr, operator, right
      end

      expr
    end

    def unary
      if match TokenType::BANG, TokenType::MINUS
        operator = previous
        right = unary
        return Expr::Unary.new operator, right
      end

      primary
    end

    def primary
      return Expr::Literal.new false if match TokenType::FALSE
      return Expr::Literal.new true if match TokenType::TRUE
      return Expr::Literal.new nil if match TokenType::NIL
      return Expr::Literal.new previous.literal if match TokenType::NUMBER, TokenType::STRING

      if match TokenType::LEFT_PAREN
        expr = expression
        consume TokenType::RIGHT_PAREN, "Expect ')' after expression."
        Expr::Grouping.new expr
      end
    end
  end
end
