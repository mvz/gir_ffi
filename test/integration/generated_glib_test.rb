require 'gir_ffi_test_helper'

# Tests generated classes, methods and functions in the GLib namespace.
describe "The generated GLib module" do
  it "can auto-generate the GLib::IConv class" do
    klass = GLib::IConv

    klass.must_be_instance_of Class
  end
end
