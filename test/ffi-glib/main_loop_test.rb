# frozen_string_literal: true
require 'gir_ffi_test_helper'

class MainLoopTestException < RuntimeError; end

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

    it 'raises and quits on exceptions in callbacks' do
      main_loop = GLib::MainLoop.new nil, false

      a = 'expected'

      # This timeout shouldn't get called
      guard = GLib.timeout_add GLib::PRIORITY_DEFAULT, 150 do
        a = 'unexpected'
        main_loop.quit
      end

      GLib.timeout_add GLib::PRIORITY_DEFAULT, 10 do
        raise MainLoopTestException
      end

      -> { main_loop.run }.must_raise MainLoopTestException
      a.must_equal 'expected'

      # Clean up uncalled timeout
      GLib.source_remove guard
    end
  end
end
