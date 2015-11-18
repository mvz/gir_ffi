require 'gir_ffi_test_helper'

describe 'The generated WarnLib module' do
  before do
    begin
      GirFFI.setup :WarnLib
    rescue
      skip 'WarnLib GIR not available'
    end
  end

  describe 'WarnLib::Whatever' do
    it 'has a working method #do_boo' do
      skip 'Needs testing'
    end
    it 'has a working method #do_moo' do
      skip 'Needs testing'
    end
  end
  it 'has a working function #throw_unpaired' do
    skip 'Needs testing'
  end
  it 'has a working function #unpaired_error_quark' do
    skip 'Needs testing'
  end
end
