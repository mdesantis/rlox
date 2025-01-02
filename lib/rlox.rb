# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  'rlox' => 'RLox'
)
loader.setup

class RLox
  class RuntimeError < RuntimeError
    attr_reader :token

    def initialize(token, message)
      super message
      @token = token
    end
  end

  class << self
    def main
      case ARGV.size
      when 1 then run_file ARGV[0]
      when 0 then run_prompt
      else
        warn 'Usage: rlox [script]'
        exit 64
      end
    end

    def error(message, line: nil, token: nil)
      if token
        if token.type == TokenType::EOF
          report token.line, ' at end', message
        else
          report token.line, " at '#{token.lexeme}'", message
        end
      else
        report line, '', message
      end
    end

    private

    attr_accessor :had_error

    def run_file(path)
      run File.read path

      # Indicate an error in the exit code.
      exit(65) if had_error
    end

    def run_prompt
      loop do
        print '> '

        break if ARGF.eof?

        run ARGF.readline

        self.had_error = false
      end
    end

    def run(source)
      scanner = Scanner.new source
      tokens = scanner.scan_tokens

      parser = Parser.new tokens
      expression = parser.parse

      return if had_error

      puts AstPrinter.new.print expression
    end

    def report(line, where, message)
      warn "[line #{line}] Error#{where}: #{message}"

      self.had_error = true
    end
  end
end
