require 'gir_ffi_test_helper'

GirFFI.setup :Regress

describe "An exception in a callback" do
  describe "for signals" do
    let(:object) { Regress::TestSubObj.new }

    describe "when the signal is emitted synchronously" do
      it "raises an error" do
        object.signal_connect "test" do
          raise "Boom"
        end
        lambda { GObject.signal_emit object, "test" }.must_raise RuntimeError
      end
    end

    describe "when the signal is emitted during an event loop" do
      it "causes loop run to be terminated with an exception" do
        main_loop = GLib::MainLoop.new nil, false

        object.signal_connect "test" do
          begin
            raise "Boom"
          rescue => ex
            GLib::MainLoop.store_exception(ex)
            main_loop.quit
          end
        end

        emit_func = proc {
          GObject.signal_emit object, "test"
          false
        }
        GLib.timeout_add GLib::PRIORITY_DEFAULT, 1, emit_func, nil, nil
        # Guard against runaway loop
        GLib.timeout_add GLib::PRIORITY_DEFAULT, 500, proc { main_loop.quit }, nil, nil
        proc do
          main_loop.run
        end.must_raise RuntimeError
      end
    end
  end

  describe "for other callbacks" do
    describe "when the callback occurs during an event loop" do
      it "causes loop run to be terminated with an exception" do
        main_loop = GLib::MainLoop.new nil, false

        raise_func = FFI::Function.new(:bool, [:pointer]) {
          begin
            raise "Boom"
          rescue => e
            GLib::MainLoop.store_exception e
            main_loop.quit
          end
          false
        }

        GLib.timeout_add GLib::PRIORITY_DEFAULT, 1, raise_func, nil, nil
        # Guard against runaway loop
        GLib.timeout_add GLib::PRIORITY_DEFAULT, 500, proc { main_loop.quit }, nil, nil
        proc do
          main_loop.run
        end.must_raise RuntimeError
      end
    end
  end
end
