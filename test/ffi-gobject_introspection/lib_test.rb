require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

describe "loading the shared library" do
  before do
    # Avoid cluttering the error stream with method redefinition warnings.
    stub(GObjectIntrospection::Lib).attach_function { }
  end

  describe "with ABI version 0 installed" do
    before do
      stub(GObjectIntrospection::Lib).ffi_lib("girepository-1.0.so.1") { raise LoadError }
      stub(GObjectIntrospection::Lib).ffi_lib("girepository-1.0.so.0") { }
      stub(GObjectIntrospection::Lib).ffi_lib("girepository-1.0") { raise "not expected" }
    end

    it "prints a warning message" do
      _, err = capture_io do
        load 'ffi-gobject_introspection/lib.rb'
      end

      assert_match(/not supported/, err)
    end
  end

  describe "with ABI version 1 installed" do
    before do
      stub(GObjectIntrospection::Lib).ffi_lib("girepository-1.0.so.0") { raise LoadError }
      stub(GObjectIntrospection::Lib).ffi_lib("girepository-1.0.so.1") { }
      stub(GObjectIntrospection::Lib).ffi_lib("girepository-1.0") { raise "not expected" }
    end

    it "does not print a warning message" do
      _, err = capture_io do
        load 'ffi-gobject_introspection/lib.rb'
      end

      assert_equal "", err
    end
  end

  describe "without being able to determine the ABI version" do
    before do
      stub(GObjectIntrospection::Lib).ffi_lib("girepository-1.0.so.0") { raise LoadError }
      stub(GObjectIntrospection::Lib).ffi_lib("girepository-1.0.so.1") { raise LoadError }
      stub(GObjectIntrospection::Lib).ffi_lib("girepository-1.0") { }
    end

    it "prints a warning message" do
      _, err = capture_io do
        load 'ffi-gobject_introspection/lib.rb'
      end

      assert_match(/not supported/, err)
    end
  end
end
