# frozen_string_literal: true

class RLox
  class Resolver
    module FunctionType
      NONE = :"#{self}::NONE"
      FUNCTION = :"#{self}::FUNCTION"
      INITIALIZER = :"#{self}::INITIALIZER"
      METHOD = :"#{self}::METHOD"
    end

    module ClassType
      NONE = :"#{self}::NONE"
      CLASS = :"#{self}::CLASS"
      SUBCLASS = :"#{self}::SUBCLASS"
    end

    def initialize(interpreter)
      @interpreter = interpreter
      @scopes = []
      @current_function = FunctionType::NONE
      @current_class = ClassType::NONE
    end

    def resolve(statements)
      case statements
      when Stmt then resolve_statement statements
      when Expr then resolve_expression statements
      else
        statements.each do |statement|
          resolve_statement statement
        end
      end
    end

    def visit_block_stmt(stmt)
      begin_scope
      resolve stmt.statements
      end_scope

      nil
    end

    def visit_class_stmt(stmt)
      enclosing_class = current_class
      self.current_class = ClassType::CLASS

      declare stmt.name
      define stmt.name

      if stmt.superclass && stmt.name.lexeme == stmt.superclass.name.lexeme
        RLox.error "A class can't inherit from itself.", token: stmt.superclass.name
      end

      if stmt.superclass
        self.current_class = ClassType::SUBCLASS
        resolve stmt.superclass
      end

      if stmt.superclass
        begin_scope
        scopes.last['super'] = true
      end

      begin_scope
      scopes.last['this'] = true

      stmt.methods.each do |method|
        declaration = FunctionType::METHOD
        declaration = FunctionType::INITIALIZER if method.name.lexeme == 'init'
        resolve_function method, declaration
      end

      end_scope

      end_scope if stmt.superclass

      self.current_class = enclosing_class
      nil
    end

    def visit_var_stmt(stmt)
      declare stmt.name
      resolve stmt.initializer if stmt.initializer
      define stmt.name
      nil
    end

    def visit_assign_expr(expr)
      resolve expr.value
      resolve_local expr, expr.name
      nil
    end

    def visit_variable_expr(expr)
      if !scopes.empty? && scopes.last[expr.name.lexeme] == false
        RLox.error "Can't read local variable in its own initializer.", token: expr.name
      end

      resolve_local expr, expr.name
      nil
    end

    def visit_function_stmt(stmt)
      declare stmt.name
      define stmt.name

      resolve_function stmt, FunctionType::FUNCTION
      nil
    end

    def visit_expression_stmt(stmt)
      resolve stmt.expression
      nil
    end

    def visit_if_stmt(stmt)
      resolve stmt.condition
      resolve stmt.then_branch
      resolve stmt.else_branch if stmt.else_branch
      nil
    end

    def visit_print_stmt(stmt)
      resolve stmt.expression
      nil
    end

    def visit_return_stmt(stmt)
      RLox.error "Can't return from top-level code.", token: stmt.keyword if current_function == FunctionType::NONE
      if stmt.value
        if current_function == FunctionType::INITIALIZER
          RLox.error "Can't return a value from an initializer.", token: stmt.keyword
        end
        resolve stmt.value
      end

      nil
    end

    def visit_while_stmt(stmt)
      resolve stmt.condition
      resolve stmt.body
      nil
    end

    def visit_binary_expr(expr)
      resolve expr.left
      resolve expr.right
      nil
    end

    def visit_call_expr(expr)
      resolve expr.callee

      expr.arguments.each do |argument|
        resolve argument
      end

      nil
    end

    def visit_get_expr(expr)
      resolve expr.object
      nil
    end

    def visit_set_expr(expr)
      resolve expr.value
      resolve expr.object
      nil
    end

    def visit_super_expr(expr)
      if current_class == ClassType::NONE
        RLox.error "Can't user 'super' outside of a class.", token: expr.keyword
      elsif current_class != ClassType::SUBCLASS
        RLox.error "Can't use 'super' in a class with no superclass.", token: expr.keyword
      end

      resolve_local expr, expr.keyword
      nil
    end

    def visit_this_expr(expr)
      RLox.error "Can't use 'this' outside of a class.", token: expr.keyword if current_class == ClassType::NONE

      resolve_local expr, expr.keyword
    end

    def visit_grouping_expr(expr)
      resolve expr.expression
      nil
    end

    def visit_literal_expr(_expr)
      nil
    end

    def visit_logical_expr(expr)
      resolve expr.left
      resolve expr.right
      nil
    end

    def visit_unary_expr(expr)
      resolve expr.right
      nil
    end

    private

    attr_reader :interpreter, :scopes
    attr_accessor :current_function, :current_class

    def resolve_statement(stmt)
      stmt.accept self
    end

    def resolve_expression(expr)
      expr.accept self
    end

    def begin_scope
      scopes.push({})
    end

    def end_scope
      scopes.pop
    end

    def declare(name)
      return if scopes.empty?

      scope = scopes.last
      RLox.error 'Already a variable with this name in this scope.', token: name if scope.key? name.lexeme

      scope[name.lexeme] = false
    end

    def define(name)
      return if scopes.empty?

      scopes.last[name.lexeme] = true
    end

    def resolve_local(expr, name)
      (scopes.size - 1).downto(0) do |i|
        if scopes[i].key? name.lexeme
          interpreter.resolve expr, scopes.size - 1 - i
          return
        end
      end
    end

    def resolve_function(function, type)
      enclosing_function = current_function
      self.current_function = type

      begin_scope
      function.params.each do |param|
        declare param
        define param
      end
      resolve function.body
      end_scope
      self.current_function = enclosing_function
    end
  end
end
