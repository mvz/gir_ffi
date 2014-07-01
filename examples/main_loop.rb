require 'gir_ffi'

main_loop = GLib::MainLoop.new nil, false

Signal.trap("INT") do
  if main_loop.is_running
    main_loop.quit
  end
  exit
end

class Foo
  def initialize(min_delta = 0.001, timeout = 100)
    @min_delta = min_delta
    @timeout = timeout
    @handler = proc { self.idle_handler; false }
  end

  def idle_handler
    let_other_threads_run
    set_idle_proc
  end

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

foo = Foo.new

foo.idle_handler

main_loop.run
