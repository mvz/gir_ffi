require File.expand_path('test_helper.rb', File.dirname(__FILE__))

class BuilderTest < MiniTest::Spec
  context "The GirFFI::Builder module" do
    setup do
      @gir = GirFFI::IRepository.default
    end

    context "building GObject::Object" do
      before do
	save_module :GObject
	GirFFI::Builder.build_class get_function_introspection_data('GObject', 'Object')
      end

      should "create a Lib module in the parent namespace ready to attach functions from gobject-2.0" do
	expected = @gir.shared_library('GObject')
	assert_equal [expected], GObject::Lib.ffi_libraries.map(&:name)
      end

      should "create an array CALLBACKS inside the GObject::Lib module" do
	assert_equal [], GObject::Lib::CALLBACKS
      end

      should "not replace existing classes" do
	oldclass = GObject::Object
	GirFFI::Builder.build_class get_function_introspection_data('GObject', 'Object')
	assert_equal oldclass, GObject::Object
      end

      after do
        restore_module :GObject
      end
    end

    context "building Gtk::Window" do
      before do
	save_module :Gtk
	save_module :GObject
	GirFFI::Builder.build_class get_function_introspection_data('Gtk', 'Window')
      end

      should "build Gtk namespace" do
	assert Gtk.const_defined? :Lib
	assert Gtk.respond_to? :method_missing
      end

      should "build parent classes also" do
	assert Gtk.const_defined? :Widget
	assert Object.const_defined? :GObject
	assert GObject.const_defined? :InitiallyUnowned
	assert GObject.const_defined? :Object
      end

      should "set up inheritance chain" do
        ancestors = Gtk::Window.ancestors
	assert_equal [
	  Gtk::Window,
	  Gtk::Bin,
	  Gtk::Container,
	  Gtk::Widget
	], ancestors[0..3]
        assert ancestors.include? GObject::InitiallyUnowned
	assert ancestors.include? GObject::Object
      end

      should "create a Gtk::Window#to_ptr method" do
	assert Gtk::Window.instance_methods.map(&:to_sym).include? :to_ptr
      end

      should "result in Gtk::Window.new to succeed" do
	assert_nothing_raised {Gtk::Window.new(:toplevel)}
      end

      after do
	restore_module :Gtk
	restore_module :GObject
      end
    end

    context "building Gtk" do
      before do
	save_module :Gtk
	GirFFI::Builder.build_module 'Gtk'
      end

      should "create a Lib module ready to attach functions from gtk-x11-2.0" do
	# The Gtk module has more than one library on my current machine.
	expected = (@gir.shared_library 'Gtk').split(',')
	assert_equal expected.sort, Gtk::Lib.ffi_libraries.map(&:name).sort
      end

      should "create an array CALLBACKS inside the Gtk::Lib module" do
	assert_equal [], Gtk::Lib::CALLBACKS
      end

      should "not replace existing module" do
	oldmodule = Gtk
	GirFFI::Builder.build_module 'Gtk'
	assert_equal oldmodule, Gtk
      end

      should "not replace existing Lib module" do
	oldmodule = Gtk::Lib
	GirFFI::Builder.build_module 'Gtk'
	assert_equal oldmodule, Gtk::Lib
      end

      after do
	restore_module :Gtk
      end
    end

    context "looking at Gtk.main" do
      setup do
	@go = get_function_introspection_data 'Gtk', 'main'
      end

      should "have correct introspection data" do
	@gir.require "Gtk", nil
	go2 = @gir.find_by_name "Gtk", "main"
	assert_equal go2, @go
      end

      should "attach function to Whatever::Lib" do
	mod = Module.new
	mod.const_set :Lib, libmod = Module.new
	libmod.module_eval do
	  extend FFI::Library
	  ffi_lib "gtk-x11-2.0"
	end

	GirFFI::Builder.send :attach_ffi_function, libmod, @go
	assert libmod.public_methods.map(&:to_sym).include? :gtk_main
      end
    end

    context "looking at Gtk.init" do
      setup do
	GirFFI::Builder.build_module 'Gtk'
	@go = get_function_introspection_data 'Gtk', 'init'
      end

      should "have :pointer, :pointer as types of the arguments for the attached function" do
	assert_equal [:pointer, :pointer], GirFFI::Builder.send(:ffi_function_argument_types, @go)
      end

      should "have :void as return type for the attached function" do
	assert_equal :void, GirFFI::Builder.send(:ffi_function_return_type, @go)
      end
    end

    context "looking at Gtk::Widget#show" do
      setup do
	@go = get_method_introspection_data 'Gtk', 'Widget', 'show'
      end

      should "have :pointer as types of the arguments for the attached function" do
	assert_equal [:pointer], GirFFI::Builder.send(:ffi_function_argument_types, @go)
      end

    end

    context "looking at Regress.test_callback_destroy_notify" do
      before do
	save_module :GLib
	save_module :GObject
	save_module :Regress
	GirFFI::Builder.build_module 'GLib'
	GirFFI::Builder.build_module 'GObject'
	GirFFI::Builder.build_module 'Regress'
	@go = get_function_introspection_data 'Regress', 'test_callback_destroy_notify'
      end

      should "have the correct types of the arguments for the attached function" do
	argtypes = GirFFI::Builder.send(:ffi_function_argument_types, @go)
	assert_equal [Regress::TestCallbackUserData, :pointer, GLib::DestroyNotify],
	  argtypes
      end

      should "define ffi callback types :Callback and :ClosureNotify" do
	Regress.gir_ffi_builder.setup_function 'test_callback_destroy_notify'
	tcud = Regress::Lib.find_type :TestCallbackUserData
	dn = GLib::Lib.find_type :DestroyNotify

	assert_equal FFI.find_type(:int32), tcud.result_type
	assert_equal FFI.find_type(:void), dn.result_type
	assert_equal [FFI.find_type(:pointer)], tcud.param_types
	assert_equal [FFI.find_type(:pointer)], dn.param_types
      end

      # FIXME: Test passes but does not test what it claims to test.
      should "define ffi enum type ConnectFlags" do
	assert_equal({:after => 1, :swapped => 2}, GObject::ConnectFlags.to_h)
      end

      after do
	restore_module :Regress
	restore_module :GObject
	restore_module :GLib
      end
    end

    context "building Regress::TestStructA" do
      setup do
	@fieldnames = [:some_int, :some_int8, :some_double, :some_enum]
	GirFFI::Builder.build_class get_function_introspection_data('Regress', 'TestStructA')
      end

      should "set up the correct struct members" do
	assert_equal @fieldnames,
	  Regress::TestStructA::Struct.members
      end

      should "set up struct members with the correct offset" do
	info = @gir.find_by_name 'Regress', 'TestStructA'
	assert_equal info.fields.map{|f| [f.name.to_sym, f.offset]},
	  Regress::TestStructA::Struct.offsets
      end

      should "set up struct members with the correct types" do
	tags = [:int, :int8, :double, Regress::TestEnum]
	assert_equal tags.map {|t| FFI.find_type t},
	  @fieldnames.map {|f| Regress::TestStructA::Struct.layout[f].type}
      end
    end

    context "building GObject::TypeCValue" do
      setup do
	GirFFI::Builder.build_class get_function_introspection_data('GObject', 'TypeCValue')
      end

      should "set up the correct union members" do
	assert_equal [:v_int, :v_long, :v_int64, :v_double, :v_pointer],
	  GObject::TypeCValue::Struct.members
      end

      should "set up union members with the correct offset" do
	assert_equal [0, 0, 0, 0, 0],
	  GObject::TypeCValue::Struct.offsets.map {|o| o[1]}
      end

      should "set up the inner class as derived from FFI::Union" do
	assert_equal FFI::Union, GObject::TypeCValue::Struct.superclass
      end
    end

    context "building GObject::ValueArray" do
      should "use provided constructor if present" do
	GirFFI::Builder.build_class get_function_introspection_data('GObject', 'ValueArray')
	assert_nothing_raised {
	  GObject::ValueArray.new 2
	}
      end
    end

    context "building Regress::TestBoxed" do
      setup do
	GirFFI::Builder.build_class get_function_introspection_data('Regress', 'TestBoxed')
      end

      should "set up #wrap" do
	assert Regress::TestBoxed.respond_to? "wrap"
      end

      should "set up #allocate" do
	assert Regress::TestBoxed.respond_to? "allocate"
      end
    end

    context "built Regress module" do
      before do
	save_module :Regress
	GirFFI::Builder.build_module 'Regress'
      end

      should "have a method_missing method" do
	ms = (Regress.public_methods - Module.public_methods).map(&:to_sym)
	assert ms.include? :method_missing
      end

      should "autocreate the TestObj class" do
	assert !Regress.const_defined?(:TestObj)
	assert_nothing_raised {Regress::TestObj}
	assert Regress.const_defined? :TestObj
      end

      should "know its own module builder" do
	assert GirFFI::Builder::Module === Regress.gir_ffi_builder
      end

      after do
        restore_module :Regress
      end
    end

    context "built Regress::TestObj" do
      before do
	save_module :Regress
	GirFFI::Builder.build_class get_function_introspection_data('Regress', 'TestObj')
      end

      should "make autocreated instance method available to all instances" do
	o1 = Regress::TestObj.new_from_file("foo")
	o2 = Regress::TestObj.new_from_file("foo")
	o1.instance_method
	Regress::TestObj.class_eval do
	  undef method_missing
	end
	assert_nothing_raised { o2.instance_method }
      end

      should "attach C functions to Regress::Lib" do
	o = Regress::TestObj.new_from_file("foo")
	o.instance_method
	assert Regress::Lib.respond_to? :regress_test_obj_instance_method
      end

      should "know its own GIR info" do
	assert_equal 'TestObj', Regress::TestObj.gir_info.name
      end

      should "know its own class builder" do
	assert GirFFI::Builder::Type::Base === Regress::TestObj.gir_ffi_builder
      end

      context "its #torture_signature_0 method" do
	should "have the correct types of the arguments for the attached function" do
	  info = get_method_introspection_data 'Regress', 'TestObj',
	    'torture_signature_0'
	  assert_equal [:pointer, :int32, :pointer, :pointer, :pointer, :pointer, :uint32],
	    GirFFI::Builder.send(:ffi_function_argument_types, info)
	end
      end

      after do
        restore_module :Regress
      end
    end

    context "built Regress::TestSubObj" do
      before do
	save_module :Regress
	GirFFI::Builder.build_class get_function_introspection_data('Regress', 'TestSubObj')
      end

      should "autocreate parent class' set_bare inside the parent class" do
	o1 = Regress::TestSubObj.new
	o2 = Regress::TestObj.new_from_file("foo")

	assert_nothing_raised {o1.set_bare(nil)}

	Regress::TestObj.class_eval do
	  undef method_missing
	end

	assert_nothing_raised {o2.set_bare(nil)}
      end

      should "use its own version of instance_method when parent's version has been created" do
	obj = Regress::TestObj.new_from_file("foo")
	assert_equal(-1, obj.instance_method)
	subobj = Regress::TestSubObj.new
	assert_equal 0, subobj.instance_method
      end

      after do
        restore_module :Regress
      end
    end

    context "built Gio::ThreadedSocketService" do
      before do
	save_module :Gio
	GirFFI::Builder.build_module 'Gio'
      end

      context "when parent constructor has been called" do
	setup do
	  Gio::SocketService.new
	end

	should "still use its own constructor" do
	  assert_nothing_raised { Gio::ThreadedSocketService.new 2 }
	end
      end

      after do
        restore_module :Gio
      end
    end
  end
end
