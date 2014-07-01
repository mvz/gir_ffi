GLib.load_class :MainLoop

module GLib
  class MainLoop
    class ThreadEnabler
      def initialize(min_delta = 0.001, timeout = 10)
        @min_delta = min_delta
        @timeout = timeout
        @handler = proc { self.idle_handler; false }
      end

      def idle_handler
        let_other_threads_run
        set_idle_proc
      end

      private

      def let_other_threads_run
        @before = Time.now
        Thread.pass
        @after = Time.now
      end

      def delta
        @after - @before
      end

      def set_idle_proc
        if delta < @min_delta
          GLib.timeout_add(GLib::PRIORITY_DEFAULT, @timeout, @handler, nil, nil)
        else
          GLib.idle_add(GLib::PRIORITY_DEFAULT_IDLE, @handler, nil, nil)
        end
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
