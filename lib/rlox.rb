# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  'rlox' => 'RLox'
)
loader.setup

module RLox
end
