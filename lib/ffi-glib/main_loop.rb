GLib.load_class :MainLoop

module GLib
  class MainLoop
    class ThreadEnabler
      def initialize
        @handler = proc { self.idle_handler; false }
      end

      def idle_handler
        let_other_threads_run
        set_idle_proc
      end

      def let_other_threads_run
        Thread.pass
      end

      def set_idle_proc
        GLib.idle_add(GLib::PRIORITY_DEFAULT_IDLE, @handler, nil, nil)
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
