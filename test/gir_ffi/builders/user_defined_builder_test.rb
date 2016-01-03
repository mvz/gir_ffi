require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::Builders::UserDefinedBuilder do
  let(:klass) do
    Object.const_set("DerivedClass#{Sequence.next}",
                     Class.new(GIMarshallingTests::Object))
  end
  let(:builder) { GirFFI::Builders::UserDefinedBuilder.new info }
  let(:info) { GirFFI::UserDefinedTypeInfo.new klass }

  describe '#build_class' do
    before do
      builder.build_class
    end

    describe 'with type info containing one property' do
      let(:info) do
        GirFFI::UserDefinedTypeInfo.new klass do |it|
          it.install_property GObject.param_spec_int('foo', 'foo bar',
                                                     'The Foo Bar Property',
                                                     10, 20, 15,
                                                     3)
        end
      end

      it 'registers a type that is bigger than the parent' do
        gtype = klass.gtype
        q = GObject.type_query gtype
        q.instance_size.must_be :>, GIMarshallingTests::Object::Struct.size
      end

      it 'gives the types Struct the fields :parent and :foo' do
        klass::Struct.members.must_equal [:parent, :foo]
      end

      it 'creates accessor functions for the property' do
        obj = klass.new
        obj.foo = 13
        obj.foo.must_equal 13
      end

      it 'makes the property retrievable using #get_property' do
        obj = klass.new
        obj.foo = 13
        obj.get_property('foo').must_equal 13
      end

      it 'makes the property settable using #set_property' do
        obj = klass.new
        obj.set_property('foo', 20)
        obj.foo.must_equal 20
      end
    end

    describe 'with type info containing an overridden g_name' do
      let(:info) do
        GirFFI::UserDefinedTypeInfo.new klass do |it|
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
        GirFFI::UserDefinedTypeInfo.new klass do |it|
          it.install_vfunc_implementation :method_int8_in, proc {|instance, in_|
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
        GirFFI::UserDefinedTypeInfo.new klass do |it|
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
