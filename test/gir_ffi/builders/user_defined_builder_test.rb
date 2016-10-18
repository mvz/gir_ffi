# frozen_string_literal: true
require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests
GirFFI.setup :Regress

describe GirFFI::Builders::UserDefinedBuilder do
  let(:klass) do
    Object.const_set("DerivedClass#{Sequence.next}",
                     Class.new(GIMarshallingTests::Object))
  end
  let(:builder) { GirFFI::Builders::UserDefinedBuilder.new info }
  let(:info) { GirFFI::UserDefinedObjectInfo.new klass }

  describe '#build_class' do
    before do
      builder.build_class
    end

    describe 'with type info containing one integer property' do
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_int('foo-bar', 'foo bar',
                                                     'The Foo Bar Property',
                                                     10, 20, 15,
                                                     readable: true, writable: true)
        end
      end

      it 'registers a type that is bigger than the parent' do
        gtype = klass.gtype
        q = GObject.type_query gtype
        q.instance_size.must_be :>, GIMarshallingTests::Object::Struct.size
      end

      it "gives the type's Struct fields for the parent and the property" do
        klass::Struct.members.must_equal [:parent, :foo_bar]
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        obj.foo_bar = 13
        obj.foo_bar.must_equal 13
      end

      it 'makes the property retrievable using #get_property' do
        obj = klass.new
        obj.foo_bar = 13
        obj.get_property('foo-bar').must_equal 13
      end

      it 'makes the property settable using #set_property' do
        obj = klass.new
        obj.set_property('foo-bar', 20)
        obj.foo_bar.must_equal 20
      end

      it 'keeps parent properties accessible through their accessors' do
        obj = klass.new
        obj.int = 24
        obj.int.must_equal 24
      end

      it 'keeps parent properties accessible through get_property and set_property' do
        obj = klass.new
        obj.set_property('int', 24)
        obj.get_property('int').must_equal 24
      end
    end

    describe 'with type info containing properties of several different types' do
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_string('string-prop', 'string property',
                                                        'The String Property',
                                                        'this is the default value',
                                                        readable: true, writable: true)
          it.install_property GObject.param_spec_int('int-prop', 'integer property',
                                                     'The Integer Property',
                                                     10, 20, 15,
                                                     readable: true, writable: true)
          it.install_property GObject.param_spec_long('long-prop', 'long property',
                                                      'The Long Property',
                                                      10.0, 50.0, 42.0,
                                                      readable: true, writable: true)
        end
      end

      it 'registers a type of the proper size' do
        expected_size = klass::Struct.size
        gtype = klass.gtype
        q = GObject.type_query gtype
        q.instance_size.must_equal expected_size
      end

      it "gives the type's Struct fields for the parent and the properties with the correct offsets" do
        offsets = klass::Struct.offsets
        alignment = klass::Struct.alignment
        alignment.must_equal 8 # TODO: Fix tests for platforms where this fails.
        offsets.must_equal [[:parent, 0], [:string_prop, 32], [:int_prop, 40], [:long_prop, 48]]
      end

      it 'creates accessor functions for the string property' do
        obj = klass.new
        obj.string_prop = 'hello!'
        obj.string_prop.must_equal 'hello!'
      end

      it 'creates accessor functions for the integer property' do
        obj = klass.new
        obj.int_prop = 13
        obj.int_prop.must_equal 13
      end
    end

    describe 'with a boxed property' do
      let(:boxed_gtype) { GIMarshallingTests::BoxedStruct.gtype }
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_boxed('boxed-prop', 'boxed property',
                                                       'The Boxed Property',
                                                       boxed_gtype,
                                                       readable: true, writable: true)
        end
      end

      it 'registers a type of the proper size' do
        expected_size = klass::Struct.size
        gtype = klass.gtype
        q = GObject.type_query gtype
        q.instance_size.must_equal expected_size
      end

      it "gives the type's Struct fields for the parent and the property" do
        klass::Struct.members.must_equal [:parent, :boxed_prop]
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        boxed = GIMarshallingTests::BoxedStruct.new
        boxed.long_ = 423
        obj.boxed_prop = boxed
        obj.boxed_prop.long_.must_equal 423
      end
    end

    describe 'with an object property' do
      let(:object_gtype) { GIMarshallingTests::Object.gtype }
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_object('object-prop', 'object property',
                                                        'The Object Property',
                                                        object_gtype,
                                                        readable: true, writable: true)
        end
      end

      it 'registers a type of the proper size' do
        expected_size = klass::Struct.size
        gtype = klass.gtype
        q = GObject.type_query gtype
        q.instance_size.must_equal expected_size
      end

      it "gives the type's Struct fields for the parent and the property" do
        klass::Struct.members.must_equal [:parent, :object_prop]
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        object = GIMarshallingTests::Object.new 42
        object.int = 423
        obj.object_prop = object
        obj.object_prop.int.must_equal 423
      end
    end

    describe 'with a boolean property' do
      let(:object_gtype) { GIMarshallingTests::Object.gtype }
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_boolean('the-prop', 'the property',
                                                         'The Property',
                                                         true,
                                                         readable: true, writable: true)
        end
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        obj.the_prop = true
        obj.the_prop.must_equal true
      end
    end

    describe 'with a char property' do
      let(:object_gtype) { GIMarshallingTests::Object.gtype }
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_char('the-prop', 'the property',
                                                      'The Property',
                                                      -20, 100, 15,
                                                      readable: true, writable: true)
        end
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        obj.the_prop = -13
        obj.the_prop.must_equal(-13)
      end
    end

    describe 'with a uchar property' do
      let(:object_gtype) { GIMarshallingTests::Object.gtype }
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_uchar('the-prop', 'the property',
                                                       'The Property',
                                                       10, 100, 15,
                                                       readable: true, writable: true)
        end
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        obj.the_prop = 13
        obj.the_prop.must_equal 13
      end
    end

    describe 'with a uint property' do
      let(:object_gtype) { GIMarshallingTests::Object.gtype }
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_uint('the-prop', 'the property',
                                                      'The Property',
                                                      10, 100, 15,
                                                      readable: true, writable: true)
        end
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        obj.the_prop = 423
        obj.the_prop.must_equal 423
      end
    end

    describe 'with a ulong property' do
      let(:object_gtype) { GIMarshallingTests::Object.gtype }
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_ulong('the-prop', 'the property',
                                                       'The Property',
                                                       10, 100, 15,
                                                       readable: true, writable: true)
        end
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        obj.the_prop = 423_432
        obj.the_prop.must_equal 423_432
      end
    end

    describe 'with a int64 property' do
      let(:object_gtype) { GIMarshallingTests::Object.gtype }
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_int64('the-prop', 'the property',
                                                       'The Property',
                                                       10, 100, 15,
                                                       readable: true, writable: true)
        end
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        obj.the_prop = -423_432
        obj.the_prop.must_equal(-423_432)
      end
    end

    describe 'with a uint64 property' do
      let(:object_gtype) { GIMarshallingTests::Object.gtype }
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_uint64('the-prop', 'the property',
                                                        'The Property',
                                                        10, 100, 15,
                                                        readable: true, writable: true)
        end
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        obj.the_prop = 423_432
        obj.the_prop.must_equal 423_432
      end
    end

    describe 'with a float property' do
      let(:object_gtype) { GIMarshallingTests::Object.gtype }
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_float('the-prop', 'the property',
                                                       'The Property',
                                                       10.0, 100.0, 15.0,
                                                       readable: true, writable: true)
        end
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        obj.the_prop = 42.23
        obj.the_prop.must_be_within_epsilon 42.23
      end
    end

    describe 'with a double property' do
      let(:object_gtype) { GIMarshallingTests::Object.gtype }
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_double('the-prop', 'the property',
                                                        'The Property',
                                                        10.0, 100.0, 15.0,
                                                        readable: true, writable: true)
        end
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        obj.the_prop = 42.23
        obj.the_prop.must_equal 42.23
      end
    end

    describe 'with an enum property' do
      let(:object_gtype) { GIMarshallingTests::Object.gtype }
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          prop = GObject.param_spec_enum('the-prop', 'the property',
                                         'The Property',
                                         GIMarshallingTests::GEnum.gtype, 0,
                                         readable: true, writable: true)
          it.install_property prop
        end
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        obj.the_prop = :value2
        obj.the_prop.must_equal :value2
      end
    end

    describe 'with a flags property' do
      let(:object_gtype) { GIMarshallingTests::Object.gtype }
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          prop = GObject.param_spec_flags('the-prop', 'the property',
                                          'The Property',
                                          GIMarshallingTests::Flags.gtype, 0,
                                          readable: true, writable: true)
          it.install_property prop
        end
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        obj.the_prop = { value2: true }
        obj.the_prop.must_equal value2: true
      end
    end

    describe 'when deriving from a class with hidden struct size' do
      let(:parent_class) { Regress::TestInheritDrawable }
      let(:parent_size) do
        GObject.type_query(parent_class.gtype).instance_size
      end
      let(:klass) do
        Object.const_set("DerivedClass#{Sequence.next}", Class.new(parent_class))
      end
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_property GObject.param_spec_int('int-prop', 'integer property',
                                                     'Integer Property',
                                                     10, 20, 15,
                                                     readable: true, writable: true)
        end
      end

      it 'registers a type that is bigger than the parent' do
        klass_size = GObject.type_query(klass.gtype).instance_size
        klass_size.must_be :>, parent_size
      end

      it 'leaves enough space in derived struct layout' do
        struct_size = klass::Struct.size
        struct_size.must_be :>, parent_size
      end
    end

    describe 'with type info containing an overridden g_name' do
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.g_name = "OtherName#{Sequence.next}"
        end
      end

      it 'registers a type under the overridden name' do
        registered_name = GObject.type_name(klass.gtype)
        registered_name.must_equal info.g_name
        registered_name.wont_equal klass.name
      end
    end

    describe 'with type info containing a vfunc' do
      let(:info) do
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_vfunc_implementation :method_int8_in, proc { |instance, in_|
            instance.int = in_
          }
        end
      end

      it 'allows the vfunc to be called through its invoker' do
        obj = klass.new
        obj.method_int8_in 12
        obj.int.must_equal 12
      end
    end

    describe 'with type info containing a vfunc from an included Interface' do
      let(:info) do
        klass.class_eval { include GIMarshallingTests::Interface }
        GirFFI::UserDefinedObjectInfo.new klass do |it|
          it.install_vfunc_implementation :test_int8_in,
                                          proc { |instance, in_| instance.int = in_ }
        end
      end

      it 'marks the type as conforming to the included Interface' do
        iface_gtype = GIMarshallingTests::Interface.gtype
        GObject.type_interfaces(klass.gtype).to_a.must_equal [iface_gtype]
      end

      it 'allows the vfunc to be called through its invoker' do
        obj = klass.new
        obj.test_int8_in 12
        obj.int.must_equal 12
      end
    end

    it 'keeps the gtype for an already registered class' do
      gtype = klass.gtype
      other_builder = GirFFI::Builders::UserDefinedBuilder.new info
      other_klass = other_builder.build_class
      other_klass.gtype.must_equal gtype
    end

    it 'creates a class with a new GType' do
      klass.gtype.wont_equal GIMarshallingTests::Object.gtype
    end

    it 'makes the registered class return objects with the correct GType' do
      obj = klass.new
      GObject.type_from_instance(obj).must_equal klass.gtype
    end
  end

  describe '#object_class_struct' do
    it 'returns the parent class struct' do
      builder.object_class_struct.must_equal GIMarshallingTests::ObjectClass
    end
  end
end
