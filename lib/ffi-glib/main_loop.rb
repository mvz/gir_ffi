GLib.load_class :MainLoop

module GLib
  class MainLoop
    class ThreadEnabler
      FRAMERATE = 25
      DEFAULT_TIMEOUT = 1000 / FRAMERATE
      def initialize(min_delta = 0.001, timeout = DEFAULT_TIMEOUT)
        @min_delta = min_delta
        @timeout = timeout
        @handler = proc { let_other_threads_run; true }
      end

      def idle_handler
        GLib.timeout_add(GLib::PRIORITY_DEFAULT, @timeout, @handler, nil, nil)
      end

      private

      def let_other_threads_run
        Thread.pass
      end
    end

    setup_instance_method "run_with_thread_enabler"

    def run_with_thread_enabler
      @enabler = ThreadEnabler.new
      @enabler.idle_handler
      run_without_thread_enabler
    end

    alias run_without_thread_enabler run
    alias run run_with_thread_enabler
  end
end
