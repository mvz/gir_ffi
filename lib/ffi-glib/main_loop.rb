# frozen_string_literal: true

require "singleton"

GLib.load_class :MainLoop

module GLib
  # Overrides for GMainLoop, GLib's event loop
  class MainLoop
    # Class encapsulationg logic for running an idle handler to make Ruby code
    # run during GLib's event loop.
    class ThreadEnabler
      include Singleton

      FRAMERATE = 25
      DEFAULT_TIMEOUT = 1000 / FRAMERATE

      def initialize(timeout = DEFAULT_TIMEOUT)
        @timeout = timeout
      end

      def setup_idle_handler
        @handler_id ||=
          GLib.timeout_add(GLib::PRIORITY_DEFAULT, @timeout, &handler_proc)
      end

      private

      def handler_proc
        proc do
          ::Thread.pass
          true
        end
      end
    end

    EXCEPTIONS = []
    RUNNING_LOOPS = []

    setup_instance_method! :run

    def run_with_thread_enabler
      ThreadEnabler.instance.setup_idle_handler if RUBY_ENGINE == "ruby"
      RUNNING_LOOPS << self
      result = run_without_thread_enabler
      exception = EXCEPTIONS.shift
      RUNNING_LOOPS.pop
      raise exception if exception

      result
    end

    def self.handle_exception(exception)
      current_loop = RUNNING_LOOPS.last
      raise exception unless current_loop

      EXCEPTIONS << exception
      current_loop.quit
    end

    alias run_without_thread_enabler run
    alias run run_with_thread_enabler
  end
end

Signal.trap "INT" do
  GLib::MainLoop.handle_exception(Interrupt.new)
end
