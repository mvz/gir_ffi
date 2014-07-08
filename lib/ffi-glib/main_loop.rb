require 'singleton'

GLib.load_class :MainLoop

module GLib
  # Overrides for GMainLoop, GLib's event loop
  class MainLoop
    # Class encepsulationg logic for running an idle handler to make Ruby code
    # run during GLib's event loop.
    class ThreadEnabler
      include Singleton

      FRAMERATE = 25
      DEFAULT_TIMEOUT = 1000 / FRAMERATE

      def initialize timeout = DEFAULT_TIMEOUT
        @timeout = timeout
        @handler = if RUBY_VERSION == "1.9.2"
                     proc { sleep 0.0001; Thread.pass; true }
                   else
                     proc { Thread.pass; true }
                   end
      end

      def setup_idle_handler
        @handler_id ||= GLib.timeout_add(GLib::PRIORITY_DEFAULT,
                                         @timeout, @handler,
                                         nil, nil)
      end
    end

    setup_instance_method "run_with_thread_enabler"

    def run_with_thread_enabler
      ThreadEnabler.instance.setup_idle_handler
      run_without_thread_enabler
    end

    alias run_without_thread_enabler run
    alias run run_with_thread_enabler
  end
end
