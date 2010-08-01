require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'girffi/builder'

class BuilderTest < Test::Unit::TestCase
  context "The GirFFI::Builder module" do
    # TODO: Use gir's sample Everything library for testing instead.
    context "building GObject::Object" do
      setup do
	GirFFI::Builder.build_class 'GObject', 'Object', 'NS1'
      end

      should "create a method_missing method for the class" do
	ms = NS1::GObject::Object.instance_methods(false).map(&:to_sym)
	assert_contains ms, :method_missing
      end

      should "create a Lib module in the parent namespace ready to attach functions from gobject-2.0" do
	gir = GirFFI::IRepository.default
	expected = gir.shared_library 'GObject'
	assert_same_elements [*expected], NS1::GObject::Lib.ffi_libraries.map(&:name)
      end

      should "create an array CALLBACKS inside the GObject::Lib module" do
	assert_equal [], NS1::GObject::Lib::CALLBACKS
      end

      should "not replace existing classes" do
	oldclass = NS1::GObject::Object
	GirFFI::Builder.build_class 'GObject', 'Object', 'NS1'
	assert_equal oldclass, NS1::GObject::Object
      end
    end

    context "building Gtk::Window" do
      setup do
	GirFFI::Builder.build_class 'Gtk', 'Window', 'NS3'
      end

      should "build Gtk namespace" do
	assert NS3::Gtk.const_defined? :Lib
	assert NS3::Gtk.respond_to? :method_missing
      end

      should "build parent classes also" do
	assert NS3::Gtk.const_defined? :Widget
	assert NS3::Gtk.const_defined? :Object
	assert NS3.const_defined? :GObject
	assert NS3::GObject.const_defined? :InitiallyUnowned
	assert NS3::GObject.const_defined? :Object
      end

      should "set up inheritence chain" do
	assert_equal [
	  NS3::Gtk::Window,
	  NS3::Gtk::Bin,
	  NS3::Gtk::Container,
	  NS3::Gtk::Widget,
	  NS3::Gtk::Object,
	  NS3::GObject::InitiallyUnowned,
	  NS3::GObject::Object
	], NS3::Gtk::Window.ancestors[0..6]
      end

      should "create a Gtk::Window#to_ptr method" do
	assert_contains NS3::Gtk::Window.instance_methods.map(&:to_sym), :to_ptr
      end

      should "attach gtk_window_new to Gtk::Lib" do
	assert NS3::Gtk::Lib.respond_to? :gtk_window_new
      end

      should "result in Gtk::Window.new to succeed" do
	assert_nothing_raised {NS3::Gtk::Window.new(:toplevel)}
      end
    end

    context "building Gtk" do
      setup do
	GirFFI::Builder.build_module 'Gtk', 'NS2'
      end

      should "create a Lib module ready to attach functions from gtk-x11-2.0" do
	# The Gtk module has more than one library on my current machine.
	gir = GirFFI::IRepository.default
	expected = (gir.shared_library 'Gtk').split(',')
	assert_same_elements expected, NS2::Gtk::Lib.ffi_libraries.map(&:name)
      end

      should "create an array CALLBACKS inside the Gtk::Lib module" do
	assert_equal [], NS2::Gtk::Lib::CALLBACKS
      end

      should "not replace existing module" do
	oldmodule = NS2::Gtk
	GirFFI::Builder.build_module 'Gtk', 'NS2'
	assert_equal oldmodule, NS2::Gtk
      end

      should "not replace existing Lib module" do
	oldmodule = NS2::Gtk::Lib
	GirFFI::Builder.build_module 'Gtk', 'NS2'
	assert_equal oldmodule, NS2::Gtk::Lib
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
	@go = get_function_introspection_data 'GObject', 'signal_connect_data'
      end

      should "delegate definition to FunctionDefinitionBuilder" do
	code = GirFFI::Builder.send :function_definition, @go, Lib
	expected = GirFFI::FunctionDefinitionBuilder.new(@go, Lib).generate
	assert_equal cws(expected), cws(code)
      end

      should "have the correct types of the arguments for the attached function" do
	assert_equal [:pointer, :string, :Callback, :pointer, :ClosureNotify, :ConnectFlags],
	  GirFFI::Builder.send(:ffi_function_argument_types, @go)
      end

      should "define ffi callback types :Callback and :ClosureNotify" do
	lb = Module.new
	lb.extend FFI::Library

	assert_raises(TypeError) { lb.find_type :Callback }
	assert_raises(TypeError) { lb.find_type :ClosureNotify }

	GirFFI::Builder.send :define_ffi_types, lb, @go

	cb = lb.find_type :Callback
	cn = lb.find_type :ClosureNotify

	assert_equal FFI.find_type(:void), cb.result_type
	assert_equal FFI.find_type(:void), cn.result_type
	assert_equal [], cb.param_types
	assert_equal [FFI.find_type(:pointer), FFI.find_type(:pointer)], cn.param_types
      end

      should "define ffi enum type :ConnectFlags" do
	lb = Module.new
	lb.extend FFI::Library
	GirFFI::Builder.send :define_ffi_types, lb, @go
	assert_equal({:after => 1, :swapped => 2}, lb.find_type(:ConnectFlags).to_h)
      end
    end

    context "setting up Everything::TestBoxed" do
      setup do
	GirFFI::Builder.build_class 'Everything', 'TestBoxed'
      end

      should "set up #_real_new as an alias to #new" do
	assert Everything::TestBoxed.respond_to? "_real_new"
      end

      should "allow creation using #new" do
	tb = Everything::TestBoxed.new
	assert_instance_of Everything::TestBoxed, tb
      end

      should "allow creation using alternative constructors" do
	tb = Everything::TestBoxed.new_alternative_constructor1 1
	assert_instance_of Everything::TestBoxed, tb
	tb = Everything::TestBoxed.new_alternative_constructor2 1, 2
	assert_instance_of Everything::TestBoxed, tb
	tb = Everything::TestBoxed.new_alternative_constructor3 "hello"
	assert_instance_of Everything::TestBoxed, tb
      end
    end

    # TODO: Should not allow functions to be called as methods, etc.

    context "looking at Everything's functions" do
      setup do
	GirFFI::Builder.build_module 'Everything'
      end

      should "correctly handle test_boolean" do
	assert_equal false, Everything.test_boolean(false)
	assert_equal true, Everything.test_boolean(true)
      end

      should "correctly handle test_callback_user_data" do
	a = :foo
	result = Everything.test_callback_user_data Proc.new {|u|
	  a = u
	  5
	}, :bar
	assert_equal :bar, a
	assert_equal 5, result
      end
    end

    context "building the Everything module" do
      setup do
	GirFFI::Builder.build_module 'Everything', 'NS4'
      end

      should "create a method_missing method for the module" do
	ms = (NS4::Everything.public_methods - Module.public_methods).map(&:to_sym)
	assert_contains ms, :method_missing
      end

      should "cause the TestObj class to be autocreated" do
	assert !NS4::Everything.const_defined?(:TestObj)
	assert_nothing_raised {NS4::Everything::TestObj}
	assert NS4::Everything.const_defined? :TestObj
      end
    end
  end
end
