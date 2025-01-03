# frozen_string_literal: true

class RLox
  class Parser
    class ParseError < ::RuntimeError; end

    def initialize(tokens)
      self.tokens = tokens
      self.current = 0
    end

    def parse
      statements = []
      statements.push declaration until at_end?

      statements
    end

    private

    attr_accessor :tokens, :current

    def expression
      assignment
    end

    def declaration
      return var_declaration if match? TokenType::VAR

      statement
    rescue ParseError
      synchronize
      nil
    end

    def statement
      return for_statement if match? TokenType::FOR
      return if_statement if match? TokenType::IF
      return print_statement if match? TokenType::PRINT
      return while_statement if match? TokenType::WHILE
      return Stmt::Block.new block if match? TokenType::LEFT_BRACE

      expression_statement
    end

    def for_statement
      consume TokenType::LEFT_PAREN, "Expect '(' after 'for'."

      initializer =
        if match? TokenType::SEMICOLON
          nil
        elsif match? TokenType::VAR
          var_declaration
        else
          expression_statement
        end

      condition = nil
      condition = expression unless check TokenType::SEMICOLON

      consume TokenType::SEMICOLON, "Expect ';' after loop condition."

      increment = nil
      increment = expression unless check TokenType::RIGHT_PAREN

      consume TokenType::RIGHT_PAREN, "Expect ')' after for clauses."

      body = statement

      body = Stmt::Block.new [body, Stmt::Expression.new(increment)] if increment

      condition ||= Expr::Literal.new true
      body = Stmt::While.new condition, body

      body = Stmt::Block.new [initializer, body] if initializer

      body
    end

    def if_statement
      consume TokenType::LEFT_PAREN, "Expect '(' after 'if'."
      condition = expression
      consume TokenType::RIGHT_PAREN, "Expect ')' after if condition."

      then_branch = statement
      else_branch = nil
      else_branch = statement if match? TokenType::ELSE

      Stmt::If.new condition, then_branch, else_branch
    end

    def print_statement
      value = expression
      consume TokenType::SEMICOLON, "Expect ';' after value."
      Stmt::Print.new value
    end

    def while_statement
      consume TokenType::LEFT_PAREN, "Expect '(' after 'while'."
      condition = expression
      consume TokenType::RIGHT_PAREN, "Expect ')' after 'while'."
      body = statement

      Stmt::While.new condition, body
    end

    def expression_statement
      expr = expression
      consume TokenType::SEMICOLON, "Expect ';' after expression."
      Stmt::Expression.new expr
    end

    def block
      statements = []

      statements.push declaration while !check(TokenType::RIGHT_BRACE) && !at_end?

      consume TokenType::RIGHT_BRACE, "Expect '}' after block."
      statements
    end

    def assignment
      expr = logical_or

      if match? TokenType::EQUAL
        equals = previous
        value = assignment

        if expr.is_a? Expr::Variable
          name = expr.name
          return Expr::Assign.new name, value
        end

        error equals, 'Invalid assignment target.'
      end

      expr
    end

    def logical_or
      expr = logical_and

      while match? TokenType::OR
        operator = previous
        right = logical_and
        expr = Expr::Logical.new expr, operator, right
      end

      expr
    end

    def logical_and
      expr = equality

      while match? TokenType::AND
        operator = previous
        right = equality
        expr = Expr::Logical.new expr, operator, right
      end

      expr
    end

    def var_declaration
      name = consume TokenType::IDENTIFIER, 'Expect variable name.'

      initializer = nil
      initializer = expression if match? TokenType::EQUAL

      consume TokenType::SEMICOLON, "Expect ';' after variable declaration."
      Stmt::Var.new name, initializer
    end

    def equality
      expr = comparison

      while match? TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL
        operator = previous
        right = comparison
        expr = Expr::Binary.new expr, operator, right
      end

      expr
    end

    def match?(*types)
      types.each do |type|
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

    def advance
      self.current += 1 unless at_end?
      previous
    end

    def at_end?
      peek.type == TokenType::EOF
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

      while match? TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL
        operator = previous
        right = term
        expr = Expr::Binary.new expr, operator, right
      end

      expr
    end

    def term
      expr = factor

      while match? TokenType::MINUS, TokenType::PLUS
        operator = previous
        right = factor
        expr = Expr::Binary.new expr, operator, right
      end

      expr
    end

    def factor
      expr = unary

      while match? TokenType::SLASH, TokenType::STAR
        operator = previous
        right = unary
        expr = Expr::Binary.new expr, operator, right
      end

      expr
    end

    def unary
      if match? TokenType::BANG, TokenType::MINUS
        operator = previous
        right = unary
        return Expr::Unary.new operator, right
      end

      call
    end

    def call
      expr = primary

      loop do
        break unless match? TokenType::LEFT_PAREN

        expr = finish_call expr
      end

      expr
    end

    def finish_call(callee)
      arguments = []

      unless check TokenType::RIGHT_PAREN
        begin
          arguments.push expression
        end while match? TokenType::COMMA
      end

      paren = consume TokenType::RIGHT_PAREN, "Expect ')' after arguments."

      Expr::Call.new callee, paren, arguments
    end

    def primary
      return Expr::Literal.new false if match? TokenType::FALSE
      return Expr::Literal.new true if match? TokenType::TRUE
      return Expr::Literal.new nil if match? TokenType::NIL
      return Expr::Literal.new previous.literal if match? TokenType::NUMBER, TokenType::STRING

      return Expr::Variable.new previous if match? TokenType::IDENTIFIER

      if match? TokenType::LEFT_PAREN
        expr = expression
        consume TokenType::RIGHT_PAREN, "Expect ')' after expression."
        return Expr::Grouping.new expr
      end

      error peek, 'Expect expression.'
    end

    def consume(type, message)
      return advance if check type

      error peek, message
    end

    def error(token, message)
      RLox.error message, token: token
      raise ParseError, ''
    end

    def synchronize
      advance

      until at_end?
        return if previous.type == TokenType::SEMICOLON

        case peek.type
        when
          TokenType::CLASS,
          TokenType::FUN,
          TokenType::VAR,
          TokenType::FOR,
          TokenType::IF,
          TokenType::WHILE,
          TokenType::PRINT,
          TokenType::RETURN
          return
        end

        advance
      end
    end
  end
end
