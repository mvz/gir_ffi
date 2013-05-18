require 'gir_ffi_test_helper'
require 'gir_ffi/unintrospectable_type_info'

describe GirFFI::UnintrospectableTypeInfo do
  describe "#interfaces" do
    it "finds interface infos by gtype" do
      gobject = Object.new
      gir = Object.new

      mock(gobject).type_interfaces(:some_type) { [:foo, :bar ] }
      mock(gir).find_by_gtype(:foo) { :foo_info }
      mock(gir).find_by_gtype(:bar) { :bar_info }

      info = GirFFI::UnintrospectableTypeInfo.new(:some_type, gir, gobject)

      info.interfaces.must_equal [:foo_info, :bar_info]
    end

    it "skips interfaces that have no introspection data" do
      gobject = Object.new
      gir = Object.new

      mock(gobject).type_interfaces(:some_type) { [:foo, :bar ] }
      mock(gir).find_by_gtype(:foo) { :foo_info }
      mock(gir).find_by_gtype(:bar) { nil }

      info = GirFFI::UnintrospectableTypeInfo.new(:some_type, gir, gobject)

      info.interfaces.must_equal [:foo_info]
    end
  end
end
