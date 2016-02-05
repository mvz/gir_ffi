# frozen_string_literal: true
require 'gir_ffi_test_helper'

GirFFI.setup :Gst
Gst.init []

# Tests behavior of objects in the generated Gio namespace.
describe 'the generated Gst module' do
  describe 'Gst::FakeSink' do
    let(:instance) { Gst::ElementFactory.make('fakesink', 'sink') }

    it 'allows the handoff signal to be connected and emitted' do
      a = nil
      instance.signal_connect('handoff') { a = 10 }
      GObject.signal_emit(instance, 'handoff')
      a.must_equal 10
    end

    it 'correctly fetches the name' do
      instance.name.must_equal 'sink'
    end
  end

  describe 'Gst::AutoAudioSink' do
    let(:instance) { Gst::ElementFactory.make('autoaudiosink', 'audiosink') }

    it 'correctly fetches the name' do
      instance.get_name.must_equal 'audiosink'
      instance.name.must_equal 'audiosink'
    end
  end
end
