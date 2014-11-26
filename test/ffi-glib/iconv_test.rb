require 'gir_ffi_test_helper'

describe GLib::IConv do
  describe '.open' do
    it 'creates a new instance of GLib::Iconv' do
      instance = GLib::IConv.open('ascii', 'utf-8')
      instance.must_be_instance_of GLib::IConv
    end
  end

  let(:instance) { GLib::IConv.open('ascii', 'utf-8') }

  describe '#setup_and_call' do
    it "works for the method called ''" do
      instance.setup_and_call :'', [nil, nil, nil, nil]
    end
  end
end
