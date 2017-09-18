# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe 'The generated WarnLib module' do
  before do
    begin
      GirFFI.setup :WarnLib
    rescue RuntimeError
      skip 'WarnLib GIR not available'
    end
  end

  describe 'WarnLib::Whatever' do
    let(:derived_klass) do
      Object.const_set("DerivedClass#{Sequence.next}", Class.new(GObject::Object))
    end

    before do
      @result = nil
      derived_klass.class_eval { include WarnLib::Whatever }
      GirFFI.define_type derived_klass do |info|
        info.install_vfunc_implementation :do_boo, proc { |_obj, x, _y| @result = "boo#{x}" }
        info.install_vfunc_implementation :do_moo, proc { |_obj, x, _y| @result = "moo#{x}" }
      end
    end

    let(:instance) { derived_klass.new }

    it 'has a working method #do_boo' do
      instance.do_boo 42, nil
      @result.must_equal 'boo42'
    end

    it 'has a working method #do_moo' do
      instance.do_moo 23, nil
      @result.must_equal 'moo23'
    end
  end

  it 'has a working function #throw_unpaired' do
    proc { WarnLib.throw_unpaired }.must_raise GirFFI::GLibError
  end

  it 'has a working function #unpaired_error_quark' do
    result = WarnLib.unpaired_error_quark
    GLib.quark_to_string(result).must_equal 'warnlib-unpaired-error'
  end
end
