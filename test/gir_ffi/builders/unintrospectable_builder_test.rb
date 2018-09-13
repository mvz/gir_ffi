# frozen_string_literal: true

require 'gir_ffi_test_helper'

GirFFI.setup :Gio
GirFFI.setup :Gst

describe GirFFI::Builders::UnintrospectableBuilder do
  describe 'building the GLocalFile type' do
    before do
      Gio.file_new_for_path '/'

      @gtype = GObject.type_from_name 'GLocalFile'
      @info = GirFFI::UnintrospectableTypeInfo.new(@gtype)
      @bldr = GirFFI::Builders::UnintrospectableBuilder.new(@info)
      @klass = @bldr.build_class
    end

    it 'builds a class' do
      assert_instance_of Class, @klass
    end

    it 'builds a class derived from GObject::Object' do
      assert_includes @klass.registered_ancestors, GObject::Object
    end

    it 'builds a class derived from Gio::File' do
      assert_includes @klass.registered_ancestors, Gio::File
    end

    it 'returns the same class when built again' do
      other_bldr = GirFFI::Builders::UnintrospectableBuilder.new(@info)
      other_klass = other_bldr.build_class

      assert_equal @klass, other_klass
    end

    describe 'its #find_signal method' do
      it "returns nil for a signal that doesn't exist" do
        @bldr.find_signal('foo').must_be_nil
      end

      it 'finds signals in ancestor classes' do
        signal = @bldr.find_signal 'notify'
        signal.name.must_equal 'notify'
      end
    end

    describe '#object_class_struct' do
      it 'returns the parent class struct' do
        @bldr.object_class_struct.must_equal GObject::ObjectClass
      end
    end
  end

  describe 'building the GstFakeSink type' do
    let(:instance) { Gst::ElementFactory.make('fakesink', 'sink') }
    let(:sink_class) { instance.class }
    let(:builder) { sink_class.gir_ffi_builder }

    before do
      Gst.init []
    end

    describe 'its #find_signal method' do
      it 'finds signals that are not defined in the GIR' do
        signal = builder.find_signal 'handoff'
        signal.wont_be_nil
        signal.name.must_equal 'handoff'
      end
    end
  end
end
