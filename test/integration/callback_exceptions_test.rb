require 'gir_ffi_test_helper'

GirFFI.setup :Regress

class CallbackTestException < RuntimeError; end

describe "An exception in a callback" do
  describe "for signals" do
    let(:object) { Regress::TestSubObj.new }

    before do
      object.signal_connect "test" do
        begin
          raise CallbackTestException, "Boom"
        rescue => ex
          GLib::MainLoop.handle_exception(ex)
        end
      end
    end

    describe "when the signal is emitted synchronously" do
      it "raises an error" do
        lambda { GObject.signal_emit object, "test" }.must_raise CallbackTestException
      end
    end

    describe "when the signal is emitted during an event loop" do
      it "causes loop run to be terminated with an exception" do
        main_loop = GLib::MainLoop.new nil, false

        emit_func = proc {
          GObject.signal_emit object, "test"
          false
        }
        GLib.timeout_add GLib::PRIORITY_DEFAULT, 1, emit_func, nil, nil
        # Guard against runaway loop
        GLib.timeout_add GLib::PRIORITY_DEFAULT, 500, proc { main_loop.quit }, nil, nil
        proc do
          main_loop.run
        end.must_raise CallbackTestException
      end
    end
  end

  describe "for other callbacks" do
    describe "when the callback occurs during an event loop" do
      it "causes loop run to be terminated with an exception" do
        main_loop = GLib::MainLoop.new nil, false

        raise_func = FFI::Function.new(:bool, [:pointer]) {
          begin
            raise CallbackTestException, "Boom"
          rescue => e
            GLib::MainLoop.handle_exception e
          end
          false
        }

        GLib.timeout_add GLib::PRIORITY_DEFAULT, 1, raise_func, nil, nil
        # Guard against runaway loop
        GLib.timeout_add GLib::PRIORITY_DEFAULT, 500, proc { main_loop.quit }, nil, nil
        proc do
          main_loop.run
        end.must_raise CallbackTestException
      end
    end
  end
end
