require 'gir_ffi_test_helper'

class Foo
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

describe "threading" do
  it "works while a MainLoop is running" do
    main_loop = GLib::MainLoop.new nil, false
    foo = Foo.new
    foo.idle_handler

    a = []
    GLib.timeout_add(GLib::PRIORITY_DEFAULT, 100,
                     proc { main_loop.quit },
                     nil, nil)

    slow_thread = Thread.new do
      sleep 0.001
      a << "During run"
    end

    a << "Before run"
    main_loop.run
    a << "After run"

    slow_thread.join

    a.last.must_equal "After run"
  end
end
