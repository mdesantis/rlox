# frozen_string_literal: true

class RLox::Main
  def initialize
    case ARGV.size
    when 1 then run_file ARGV[0]
    when 0 then run_prompt
    else
      warn 'Usage: rlox [script]'
      exit 64
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

    # For now, just print the tokens.
    tokens.each do |token|
      puts token
    end
  end

  def error(line, message)
    report line, '', message
  end

  def report(line, where, message)
    warn "[line #{line} Error#{where}: #{message}"

    self.had_error = true
  end
end
