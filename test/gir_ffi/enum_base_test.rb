# frozen_string_literal: true

require "gir_ffi_test_helper"

GirFFI.setup :Regress

describe GirFFI::EnumBase do
  describe ".wrap" do
    it "converts an integer to a symbol if possible" do
      _(Regress::TestEnum.wrap(1)).must_equal :value2
    end

    it "passes an integer if it cannot be converted" do
      _(Regress::TestEnum.wrap(32)).must_equal 32
    end

    it "passes a known symbol untouched" do
      _(Regress::TestEnum.wrap(:value1)).must_equal :value1
    end

    it "passes an unknown symbol untouched" do
      _(Regress::TestEnum.wrap(:foo)).must_equal :foo
    end
  end

  describe ".to_int" do
    it "passes a known integer untouched" do
      _(Regress::TestEnum.to_int(1)).must_equal 1
    end

    it "passes an unknown integer untouched" do
      _(Regress::TestEnum.to_int(32)).must_equal 32
    end

    it "convertes a known symbol to an integer" do
      _(Regress::TestEnum.to_int(:value1)).must_equal 0
    end

    it "raises an error for an unknown symbol" do
      _(-> { Regress::TestEnum.to_int(:foo) }).must_raise ArgumentError
    end
  end
end
