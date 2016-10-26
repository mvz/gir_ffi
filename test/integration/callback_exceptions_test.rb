# frozen_string_literal: true
require 'gir_ffi_test_helper'

GirFFI.setup :Regress

class CallbackTestException < RuntimeError; end

describe 'An exception in a callback' do
  describe 'for signals' do
    let(:object) { Regress::TestSubObj.new }

    before do
      object.signal_connect 'test' do
        raise CallbackTestException, 'Boom'
      end
    end

    describe 'when the signal is emitted synchronously' do
      it 'raises an error' do
        proc { GObject.signal_emit object, 'test' }.must_raise CallbackTestException
      end
    end

    describe 'when the signal is emitted during an event loop' do
      it 'causes loop run to be terminated with an exception' do
        main_loop = GLib::MainLoop.new nil, false

        GLib.timeout_add GLib::PRIORITY_DEFAULT, 1 do
          GObject.signal_emit object, 'test'
          false
        end
        # Guard against runaway loop
        GLib.timeout_add GLib::PRIORITY_DEFAULT, 500 do
          main_loop.quit
        end
        proc do
          main_loop.run
        end.must_raise CallbackTestException
      end
    end
  end

  describe 'for other callbacks' do
    describe 'when the callback occurs during an event loop' do
      it 'causes loop run to be terminated with an exception' do
        main_loop = GLib::MainLoop.new nil, false

        GLib.timeout_add GLib::PRIORITY_DEFAULT, 1 do
          raise CallbackTestException, 'Boom'
        end
        # Guard against runaway loop
        GLib.timeout_add GLib::PRIORITY_DEFAULT, 500 do
          main_loop.quit
        end

        proc do
          main_loop.run
        end.must_raise CallbackTestException
      end
    end
  end
end
