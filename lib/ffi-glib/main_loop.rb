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
        # TODO: Remove 1.9.2 option on or after July 31, 2014:
        # https://www.ruby-lang.org/en/news/2014/07/01/eol-for-1-8-7-and-1-9-2/
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
      case RUBY_ENGINE
      when 'jruby'
      when 'rbx'
      else # 'ruby' most likely
        ThreadEnabler.instance.setup_idle_handler
      end
      run_without_thread_enabler
    end

    alias_method :run_without_thread_enabler, :run
    alias_method :run, :run_with_thread_enabler
  end
end
