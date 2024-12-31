# frozen_string_literal: true

require_relative 'rlox/version'

module RLox
  module_function

  def main
    case ARGV.size
    when 1 then run_file ARGV[0]
    when 0 then run_prompt
    else
      warn 'Usage: rlox [script]'
      exit 64
    end
  end

  def run_file(path)
    run File.read path
  end

  def run_prompt
    loop do
      print '> '

      break if ARGF.eof?

      run ARGF.readline
    end
  end

  def run(source)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    # For now, just print the tokens.
    tokens.each do |token|
      puts token
    end
  end
end
