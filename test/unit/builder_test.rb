require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder do
  describe "::itypeinfo_to_callback_ffitype" do
    describe "for an :interface argument" do
      before do
        @iface = Object.new
        stub(@info = Object.new).interface { @iface }
        stub(@info).tag { :interface }
        stub(@info).pointer? { false }
      end

      it "correctly maps a :union argument to :pointer" do
        stub(@iface).info_type { :union }

        result = GirFFI::Builder.itypeinfo_to_callback_ffitype @info

        assert_equal :pointer, result
      end

      it "correctly maps a :flags argument to :int32" do
        stub(@iface).info_type { :flags }

        result = GirFFI::Builder.itypeinfo_to_callback_ffitype @info

        assert_equal :int32, result
      end
    end
  end

  describe "building Regress::TestSubObj" do
    before do
      save_module :Regress
      save_module :GObject
      GirFFI::Builder.build_class get_introspection_data('Regress', 'TestSubObj')
    end

    it "builds Regress namespace" do
      assert Regress.const_defined? :Lib
      assert Regress.respond_to? :method_missing
    end

    it "builds parent classes also" do
      assert Regress.const_defined? :TestObj
      assert Object.const_defined? :GObject
      assert GObject.const_defined? :Object
    end

    it "sets up the inheritance chain" do
      ancestors = Regress::TestSubObj.ancestors
      assert_equal [
        Regress::TestSubObj,
        Regress::TestObj,
        GObject::Object
      ], ancestors[0..2]
    end

    it "creates a Regress::TestSubObj#to_ptr method" do
      assert Regress::TestSubObj.public_method_defined? :to_ptr
    end

    after do
      restore_module :Regress
      restore_module :GObject
    end
  end

  describe "building Regress" do
    before do
      save_module :Regress
      GirFFI::Builder.build_module 'Regress'
    end

    it "creates a Lib module ready to attach functions from the shared library" do
      gir = GObjectIntrospection::IRepository.default
      expected = [gir.shared_library('Regress')]
      assert_equal expected, Regress::Lib.ffi_libraries.map(&:name)
    end

    it "creates an array CALLBACKS inside the Regress::Lib module" do
      assert_equal [], Regress::Lib::CALLBACKS
    end

    it "does not replace existing module" do
      oldmodule = Regress
      GirFFI::Builder.build_module 'Regress'
      assert_equal oldmodule, Regress
    end

    it "does not replace existing Lib module" do
      oldmodule = Regress::Lib
      GirFFI::Builder.build_module 'Regress'
      assert_equal oldmodule, Regress::Lib
    end

    after do
      restore_module :Regress
    end
  end

  describe "looking at Regress.test_array_gint32_in" do
    setup do
      save_module :Regress
      GirFFI::Builder.build_module 'Regress'
      @go = get_introspection_data 'Regress', 'test_array_gint32_in'
    end

    it "has correct introspection data" do
      gir = GObjectIntrospection::IRepository.default
      gir.require "Regress", nil
      go2 = gir.find_by_name "Regress", "test_array_gint32_in"
      assert_equal go2, @go
    end

    it "attaches function to Regress::Lib" do
      GirFFI::Builder.send :attach_ffi_function, Regress::Lib, @go
      assert_defines_singleton_method Regress::Lib, :regress_test_array_gint32_in
    end

    it "has :pointer, :pointer as types of the arguments for the attached function" do
      assert_equal [:int32, :pointer], GirFFI::Builder.send(:ffi_function_argument_types, @go)
    end

    it "has :void as return type for the attached function" do
      assert_equal :int32, GirFFI::Builder.send(:ffi_function_return_type, @go)
    end

    after do
      restore_module :Regress
    end
  end

  describe "looking at Regress::TestObj#instance_method" do
    setup do
      @go = get_method_introspection_data 'Regress', 'TestObj', 'instance_method'
    end

    it "has :pointer as types of the arguments for the attached function" do
      assert_equal [:pointer], GirFFI::Builder.send(:ffi_function_argument_types, @go)
    end
  end
end

