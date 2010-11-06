require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi/builder'

class BuilderTest < Test::Unit::TestCase
  context "The GirFFI::Builder module" do
    # TODO: Use gir's sample Everything library for testing instead.
    context "building GObject::Object" do
      setup do
	cleanup_module :GObject
	GirFFI::Builder.build_class 'GObject', 'Object'
      end

      should "create a method_missing method for the class" do
	ms = GObject::Object.instance_methods(false).map(&:to_sym)
	assert_contains ms, :method_missing
      end

      should "create a Lib module in the parent namespace ready to attach functions from gobject-2.0" do
	gir = GirFFI::IRepository.default
	expected = gir.shared_library 'GObject'
	assert_same_elements [*expected], GObject::Lib.ffi_libraries.map(&:name)
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
	assert_contains Gtk::Window.instance_methods.map(&:to_sym), :to_ptr
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
	assert_same_elements expected, Gtk::Lib.ffi_libraries.map(&:name)
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
      # TODO: function_introspection_data should not return introspection data if not a function.
      should "have correct introspection data" do
	gir = GirFFI::IRepository.default
	gir.require "Gtk", nil
	go2 = gir.find_by_name "Gtk", "main"
	assert_equal go2, @go
      end

      should "build correct definition of Gtk.main" do
	code = GirFFI::Builder.send :function_definition, @go, Lib

	expected = "def main\nLib.gtk_main\nend"

	assert_equal cws(expected), cws(code)
      end

      should "attach function to Whatever::Lib" do
	mod = Module.new
	mod.const_set :Lib, libmod = Module.new
	libmod.module_eval do
	  extend FFI::Library
	  ffi_lib "gtk-x11-2.0"
	end

	GirFFI::Builder.send :attach_ffi_function, libmod, @go
	assert_contains libmod.public_methods.map(&:to_sym), :gtk_main
      end
    end

    context "looking at Gtk.init" do
      setup do
	GirFFI::Builder.build_module 'Gtk'
	@go = get_function_introspection_data 'Gtk', 'init'
      end

      should "delegate definition to FunctionDefinitionBuilder" do
	code = GirFFI::Builder.send :function_definition, @go, Lib
	expected = GirFFI::FunctionDefinitionBuilder.new(@go, Lib).generate
	assert_equal cws(expected), cws(code)
      end

      should "have :pointer, :pointer as types of the arguments for the attached function" do
	# FIXME: Ideally, we attach the function and test that it requires
	# the correct argument types.
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

      should "delegate definition to FunctionDefinitionBuilder" do
	code = GirFFI::Builder.send :function_definition, @go, Lib
	expected = GirFFI::FunctionDefinitionBuilder.new(@go, Lib).generate
	assert_equal cws(expected), cws(code)
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

      should "delegate definition to FunctionDefinitionBuilder" do
	code = GirFFI::Builder.send :function_definition, @go, Lib
	expected = GirFFI::FunctionDefinitionBuilder.new(@go, Lib).generate
	assert_equal cws(expected), cws(code)
      end

      should "have the correct types of the arguments for the attached function" do
	assert_equal [:pointer, :string, :Callback, :pointer, :ClosureNotify, GObject::ConnectFlags],
	  GirFFI::Builder.send(:ffi_function_argument_types, @go)
      end

      should "define ffi callback types :Callback and :ClosureNotify" do
	GirFFI::Builder.setup_function 'GObject', 'signal_connect_data'
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
	GirFFI::Builder.build_class 'Everything', 'TestStructA'
      end

      should "set up the correct struct members" do
	assert_equal [:some_int, :some_int8, :some_double, :some_enum],
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
	  Everything::TestStructA::Struct.layout.fields.map(&:type)
      end
    end

    context "building Everything::TestBoxed" do
      setup do
	GirFFI::Builder.build_class 'Everything', 'TestBoxed'
      end

      should "set up #_real_new as an alias to #new" do
	assert Everything::TestBoxed.respond_to? "_real_new"
      end
    end

    # TODO: Should not allow functions to be called as methods, etc.

    context "building the Everything module" do
      setup do
	cleanup_module :Everything
	GirFFI::Builder.build_module 'Everything'
      end

      should "create a method_missing method for the module" do
	ms = (Everything.public_methods - Module.public_methods).map(&:to_sym)
	assert_contains ms, :method_missing
      end

      should "cause the TestObj class to be autocreated" do
	assert !Everything.const_defined?(:TestObj)
	assert_nothing_raised {Everything::TestObj}
	assert Everything.const_defined? :TestObj
      end
    end

    # TODO: Turn this into full test of instance method creation, including
    # inheritance issues.
    context "built Everything::TestObj" do
      setup do
	cleanup_module :Everything
	GirFFI::Builder.build_class 'Everything', 'TestObj'
      end

      should "make autocreated instance method available to all instances" do
	o1 = Everything::TestObj.new_from_file("foo")
	o2 = Everything::TestObj.new_from_file("foo")
	assert !o2.respond_to?(:instance_method)
	o1.instance_method
	assert o1.respond_to?(:instance_method)
	assert o2.respond_to?(:instance_method)
      end

      should "attach C functions to Everything::Lib" do
	o = Everything::TestObj.new_from_file("foo")
	o.instance_method
	assert Everything::Lib.respond_to? :test_obj_instance_method
      end

      should "not have regular #new as a constructor" do
	assert_raises(NoMethodError) { Everything::TestObj.new }
      end
    end

    context "built Everything::TestSubObj" do
      setup do
	cleanup_module :Everything
	GirFFI::Builder.build_class 'Everything', 'TestSubObj'
      end

      should "autocreate parent class' set_bare inside the parent class" do
	o1 = Everything::TestSubObj.new
	assert !o1.respond_to?(:set_bare)
	assert_nothing_raised {o1.set_bare(nil)}
	o2 = Everything::TestObj.new_from_file("foo")
	assert o2.respond_to?(:set_bare)
      end
    end
  end
end
