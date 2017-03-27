# frozen_string_literal: true

module GirFFI
  # Exception class to be raised when a signal is not found.
  class SignalNotFoundError < RuntimeError
    attr_reader :signal_name

    def initialize(signal_name, klass)
      @signal_name = signal_name
      @klass = klass
      super "Signal '#{signal_name}' not found in #{klass}"
    end
  end
end
