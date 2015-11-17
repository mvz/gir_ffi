require 'gir_ffi_test_helper'

# Tests generated methods and functions in the GTop namespace. This namespace
# contains types with bad names, like 'glibtop_cpu'.
describe 'The generated GTop module' do
  before do
    GirFFI.setup :GTop
  end

  describe 'Glibtop' do
    it 'can be created using Glibtop.init' do
      instance = GTop::Glibtop.init
      instance.must_be_kind_of GTop::Glibtop
    end
  end
end
