require 'gir_ffi'

main_loop = GLib::MainLoop.new nil, false

Signal.trap("INT") do
  if main_loop.is_running
    main_loop.quit
  end
  exit
end

class Foo
  def initialize(timeout = 10)
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
    ((@after - @before) * 1000).to_i
  end

  def new_timeout
    @timeout - delta
  end

  def set_idle_proc
    if delta < @timeout
      GLib.timeout_add(GLib::PRIORITY_DEFAULT, new_timeout, @handler, nil, nil)
    else
      GLib.idle_add(GLib::PRIORITY_DEFAULT_IDLE, @handler, nil, nil)
    end
  end
end

foo = Foo.new

foo.idle_handler

main_loop.run
