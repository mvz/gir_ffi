# frozen_string_literal: true

require "gir_ffi_test_helper"

GirFFI.setup :WarnLib

describe WarnLib do
  describe "WarnLib::Whatever" do
    let(:derived_klass) do
      Object.const_set(:"DerivedClass#{Sequence.next}", Class.new(GObject::Object))
    end

    before do
      @result = nil
      derived_klass.class_eval { include WarnLib::Whatever }
      derived_klass.install_vfunc_implementation :do_boo,
                                                 proc { |_obj, x, _y| @result = "boo#{x}" }
      derived_klass.install_vfunc_implementation :do_moo,
                                                 proc { |_obj, x, _y| @result = "moo#{x}" }
      GirFFI.define_type derived_klass
    end

    let(:instance) { derived_klass.new }

    it "has a working method #do_boo" do
      instance.do_boo 42, nil

      _(@result).must_equal "boo42"
    end

    it "has a working method #do_moo" do
      instance.do_moo 23, nil

      _(@result).must_equal "moo23"
    end
  end

  it "has a working function #throw_unpaired" do
    _(proc { WarnLib.throw_unpaired }).must_raise GirFFI::GLibError
  end

  it "has a working function #unpaired_error_quark" do
    result = WarnLib.unpaired_error_quark

    _(GLib.quark_to_string(result)).must_equal "warnlib-unpaired-error"
  end
end
