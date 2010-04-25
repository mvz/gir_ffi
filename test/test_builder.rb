require File.expand_path('helper.rb', File.dirname(__FILE__))
require 'girffi/builder'

class BuilderTest < Test::Unit::TestCase
  context "A Builder building GObject::Object" do
    setup do
      @builder ||= nil
      return if @builder
      @builder = GirFFI::Builder.new
      @builder.build_object 'GObject', 'Object', 'NS1'
    end

    should "create the correct set of methods for the object" do
      ms = NS1::GObject::Object.instance_methods(false)
      [ "add_toggle_ref", "add_weak_pointer", "force_floating",
	"freeze_notify", "get_data", "get_property", "get_qdata", "notify",
	"remove_toggle_ref", "remove_weak_pointer", "run_dispose",
	"set_data", "set_data_full", "set_property", "set_qdata",
	"set_qdata_full", "steal_data", "steal_qdata", "thaw_notify",
	"watch_closure", "weak_ref", "weak_unref"
      ].each do |m|
	assert_contains ms, m
      end
    end
  end

  context "A Builder building Gtk" do
    setup do
      @builder ||= nil
      return if @builder
      @builder = GirFFI::Builder.new
      @builder.build_module 'Gtk', 'NS2'
    end

    should "create the correct set of methods for the module" do
      ms = NS2::Gtk.public_methods(false)
      [ "method_missing" ].each do |m|
	assert_contains ms, m
      end
    end

    should "create a Lib module ready to attach functions from gtk-x11-2.0" do
      # The Gtk module has more than one library on my current machine.
      gir = GirFFI::IRepository.default
      expected = (gir.shared_library 'Gtk').split(',').sort
      assert_equal expected, NS2::Gtk::Lib.ffi_libraries.map(&:name).sort
    end
  end

  context "A Builder" do
    setup do
      @builder = GirFFI::Builder.new
    end

    context "looking at Gtk.main" do
      setup do
	@go = @builder.function_introspection_data 'Gtk', 'main'
      end
      # TODO: function_introspection_data should not return introspection data if not a function.
      should "have correct introspection data" do
	gir = GirFFI::IRepository.default
	gir.require "Gtk", nil
	go2 = gir.find_by_name "Gtk", "main"
	assert_equal go2, @go
      end

      should "build correct definition of Gtk.main" do
	code = @builder.function_definition @go
	assert_equal "def main\nLib.gtk_main\nend", code.gsub(/(^\s*|\s*$)/, "")
      end

      should "attach function to Whatever::Lib" do
	mod = Module.new
	mod.const_set :Lib, libmod = Module.new
	libmod.module_eval do
	  extend FFI::Library
	  ffi_lib "gtk-x11-2.0"
	end

	@builder.attach_ffi_function mod, @go
	assert_contains libmod.public_methods, "gtk_main"
      end
    end

    context "looking at Gtk.init" do
      setup do
	@go = @builder.function_introspection_data 'Gtk', 'init'
      end

      should "build correct definition of Gtk.init" do
	code = @builder.function_definition @go

	expected = "
	  def init argc, argv
	    _v1 = GirFFI::Helper::Arg.int_to_inoutptr argc
	    _v3 = GirFFI::Helper::Arg.string_array_to_inoutptr argv
	    Lib.gtk_init _v1, _v3
	    _v2 = GirFFI::Helper::Arg.outptr_to_int _v1
	    _v4 = GirFFI::Helper::Arg.outptr_to_string_array _v3, argv.nil? ? 0 : argv.size
	    return _v2, _v4
	  end
	  "

	assert_equal cws(expected), cws(code)
      end

      should "have :pointer, :pointer as types of the arguments for the attached function" do
	# FIXME: Ideally, we attach the function and test that it requires
	# the correct argument types.
	assert_equal [:pointer, :pointer], @builder.ffi_function_argument_types(@go)
      end

      should "have :void as return type for the attached function" do
	assert_equal :void, @builder.ffi_function_return_type(@go)
      end
    end
  end
end
