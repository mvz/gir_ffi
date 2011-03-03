require File.expand_path('test_helper.rb', File.dirname(__FILE__))

class BuilderTest < Test::Unit::TestCase
  context "The GirFFI::Builder module" do
    context "building GObject::Object" do
      setup do
	cleanup_module :GObject
	GirFFI::Builder.build_class 'GObject', 'Object'
      end

      should "create a Lib module in the parent namespace ready to attach functions from gobject-2.0" do
	gir = GirFFI::IRepository.default
	expected = gir.shared_library('GObject')
	assert_equal [expected], GObject::Lib.ffi_libraries.map(&:name)
      end

      should "create an array CALLBACKS inside the GObject::Lib module" do
	assert_equal [], GObject::Lib::CALLBACKS
      end

      should "not replace existing classes" do
	oldclass = GObject::Object
	GirFFI::Builder.build_class 'GObject', 'Object'
	assert_equal oldclass, GObject::Object
      end
    end

    context "building Gtk::Window" do
      setup do
	cleanup_module :Gtk
	cleanup_module :GObject
	GirFFI::Builder.build_class 'Gtk', 'Window'
      end

      should "build Gtk namespace" do
	assert Gtk.const_defined? :Lib
	assert Gtk.respond_to? :method_missing
      end

      should "build parent classes also" do
	assert Gtk.const_defined? :Widget
	assert Gtk.const_defined? :Object
	assert Object.const_defined? :GObject
	assert GObject.const_defined? :InitiallyUnowned
	assert GObject.const_defined? :Object
      end

      should "set up inheritence chain" do
	assert_equal [
	  Gtk::Window,
	  Gtk::Bin,
	  Gtk::Container,
	  Gtk::Widget,
	  Gtk::Object,
	  GObject::InitiallyUnowned,
	  GObject::Object
	], Gtk::Window.ancestors[0..6]
      end

      should "create a Gtk::Window#to_ptr method" do
	assert Gtk::Window.instance_methods.map(&:to_sym).include? :to_ptr
      end

      should "result in Gtk::Window.new to succeed" do
	assert_nothing_raised {Gtk::Window.new(:toplevel)}
      end
    end

    context "building Gtk" do
      setup do
	cleanup_module :Gtk
	GirFFI::Builder.build_module 'Gtk'
      end

      should "create a Lib module ready to attach functions from gtk-x11-2.0" do
	# The Gtk module has more than one library on my current machine.
	gir = GirFFI::IRepository.default
	expected = (gir.shared_library 'Gtk').split(',')
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
    end

    context "looking at Gtk.main" do
      setup do
	@go = get_function_introspection_data 'Gtk', 'main'
      end

      should "have correct introspection data" do
	gir = GirFFI::IRepository.default
	gir.require "Gtk", nil
	go2 = gir.find_by_name "Gtk", "main"
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

    context "looking at GObject.signal_connect_data" do
      setup do
	cleanup_module :GObject
	GirFFI::Builder.build_module 'GObject'
	@go = get_function_introspection_data 'GObject', 'signal_connect_data'
      end

      should "have the correct types of the arguments for the attached function" do
	argtypes = GirFFI::Builder.send(:ffi_function_argument_types, @go)
	assert_equal [:pointer, :pointer, GObject::Callback, :pointer, GObject::ClosureNotify, GObject::ConnectFlags],
	  argtypes
      end

      should "define ffi callback types :Callback and :ClosureNotify" do
	GObject.gir_ffi_builder.setup_function 'signal_connect_data'
	cb = GObject::Lib.find_type :Callback
	cn = GObject::Lib.find_type :ClosureNotify

	assert_equal FFI.find_type(:void), cb.result_type
	assert_equal FFI.find_type(:void), cn.result_type
	assert_equal [], cb.param_types
	assert_equal [FFI.find_type(:pointer), FFI.find_type(:pointer)], cn.param_types
      end

      should "define ffi enum type ConnectFlags" do
	assert_equal({:after => 1, :swapped => 2}, GObject::ConnectFlags.to_h)
      end
    end

    context "building Everything::TestStructA" do
      setup do
	@fieldnames = [:some_int, :some_int8, :some_double, :some_enum]
	GirFFI::Builder.build_class 'Everything', 'TestStructA'
      end

      should "set up the correct struct members" do
	assert_equal @fieldnames,
	  Everything::TestStructA::Struct.members
      end

      should "set up struct members with the correct offset" do
	info = GirFFI::IRepository.default.find_by_name 'Everything', 'TestStructA'
	assert_equal info.fields.map{|f| [f.name.to_sym, f.offset]},
	  Everything::TestStructA::Struct.offsets
      end

      should "set up struct members with the correct types" do
	tags = [:int, :int8, :double, Everything::TestEnum]
	assert_equal tags.map {|t| FFI.find_type t},
	  @fieldnames.map {|f| Everything::TestStructA::Struct.layout[f].type}
      end
    end

    context "building GObject::TypeCValue" do
      setup do
	GirFFI::Builder.build_class 'GObject', 'TypeCValue'
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
	GirFFI::Builder.build_class 'GObject', 'ValueArray'
	assert_nothing_raised {
	  GObject::ValueArray.new 2
	}
      end
    end

    context "building Everything::TestBoxed" do
      setup do
	GirFFI::Builder.build_class 'Everything', 'TestBoxed'
      end

      should "set up #wrap" do
	assert Everything::TestBoxed.respond_to? "wrap"
      end

      should "set up #allocate" do
	assert Everything::TestBoxed.respond_to? "allocate"
      end
    end

    context "built Everything module" do
      setup do
	cleanup_module :Everything
	GirFFI::Builder.build_module 'Everything'
      end

      should "have a method_missing method" do
	ms = (Everything.public_methods - Module.public_methods).map(&:to_sym)
	assert ms.include? :method_missing
      end

      should "autocreate the TestObj class" do
	assert !Everything.const_defined?(:TestObj)
	assert_nothing_raised {Everything::TestObj}
	assert Everything.const_defined? :TestObj
      end

      should "know its own module builder" do
	assert GirFFI::Builder::Module === Everything.gir_ffi_builder
      end
    end

    context "built Everything::TestObj" do
      setup do
	cleanup_module :Everything
	GirFFI::Builder.build_class 'Everything', 'TestObj'
      end

      should "make autocreated instance method available to all instances" do
	o1 = Everything::TestObj.new_from_file("foo")
	o2 = Everything::TestObj.new_from_file("foo")
	o1.instance_method
	Everything::TestObj.class_eval do
	  undef method_missing
	end
	assert_nothing_raised { o2.instance_method }
      end

      should "attach C functions to Everything::Lib" do
	o = Everything::TestObj.new_from_file("foo")
	o.instance_method
	assert Everything::Lib.respond_to? :test_obj_instance_method
      end

      should "not have regular #new as a constructor" do
	assert_raises(NoMethodError) { Everything::TestObj.new }
      end

      should "know its own GIR info" do
	assert_equal 'TestObj', Everything::TestObj.gir_info.name
      end

      should "know its own class builder" do
	assert GirFFI::Builder::Class === Everything::TestObj.gir_ffi_builder
      end

      context "its #torture_signature_0 method" do
	should "have the correct types of the arguments for the attached function" do
	  info = get_method_introspection_data 'Everything', 'TestObj',
	    'torture_signature_0'
	  assert_equal [:pointer, :int, :pointer, :pointer, :pointer, :pointer, :uint],
	    GirFFI::Builder.send(:ffi_function_argument_types, info)
	end
      end
    end

    context "built Everything::TestSubObj" do
      setup do
	cleanup_module :Everything
	GirFFI::Builder.build_class 'Everything', 'TestSubObj'
      end

      should "autocreate parent class' set_bare inside the parent class" do
	o1 = Everything::TestSubObj.new
	o2 = Everything::TestObj.new_from_file("foo")

	assert_nothing_raised {o1.set_bare(nil)}

	Everything::TestObj.class_eval do
	  undef method_missing
	end

	assert_nothing_raised {o2.set_bare(nil)}
      end

      should "use its own version of instance_method when parent's version has been created" do
	obj = Everything::TestObj.new_from_file("foo")
	assert_equal(-1, obj.instance_method)
	subobj = Everything::TestSubObj.new
	assert_equal 0, subobj.instance_method
      end
    end

    context "built Gio::ThreadedSocketService" do
      setup do
	cleanup_module :Gio
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
    end
  end
end
