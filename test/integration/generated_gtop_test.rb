require 'gir_ffi_test_helper'

# Tests generated methods and functions in the GTop namespace. This namespace
# contains types with bad names, like 'glibtop_cpu'.
describe "The generated GTop module" do
  before do
    GirFFI.setup :GTop
  end

  it "has a class Glibtop" do
    GTop::Glibtop
    pass
  end
end
