# frozen_string_literal: true

require "gir_ffi_test_helper"

GirFFI.setup :Gst
Gst.init []

# Tests behavior of objects in the generated Gio namespace.
describe "the generated Gst module" do
  describe "Gst::FakeSink" do
    let(:instance) { Gst::ElementFactory.make("fakesink", "sink") }

    it "allows the handoff signal to be connected and emitted" do
      a = nil
      instance.signal_connect("handoff") { a = 10 }
      GObject.signal_emit(instance, "handoff")

      _(a).must_equal 10
    end

    it "correctly fetches the name" do
      _(instance.name).must_equal "sink"
    end

    it "allows the can-activate-push property to be read" do
      _(instance.get_property("can-activate-push")).must_equal true
    end
  end

  describe "Gst::AutoAudioSink" do
    let(:instance) { Gst::ElementFactory.make("autoaudiosink", "audiosink") }

    it "correctly fetches the name" do
      skip "Audio sink was not created" unless instance

      _(instance.get_name).must_equal "audiosink"
      _(instance.name).must_equal "audiosink"
    end
  end
end
