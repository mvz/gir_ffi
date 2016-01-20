require 'gir_ffi_test_helper'

describe GLib::MainLoop do
  describe '#run' do
    it 'allows other threads to run' do
      main_loop = GLib::MainLoop.new nil, false

      a = []
      GLib.timeout_add GLib::PRIORITY_DEFAULT, 150 do
        main_loop.quit
      end

      slow_thread = Thread.new do
        sleep 0.001
        a << 'During run'
      end

      a << 'Before run'
      main_loop.run
      a << 'After run'

      slow_thread.join

      a.must_equal ['Before run', 'During run', 'After run']
    end
  end
end
