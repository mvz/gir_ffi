require 'gir_ffi_test_helper'

describe GirFFI::Builder::RegularReturnValue do
  let(:type_info) { Object.new }
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:builder) { GirFFI::Builder::RegularReturnValue.new(var_gen, 'foo',
                                                          type_info) }

  before do
    stub(type_info).interface_type_name { 'Bar::Foo' }
  end

  describe "for :gint32" do
    before do
      stub(type_info).flattened_tag { :gint32 }
    end

    it "has no statements in #post" do
      builder.post.must_equal []
    end

    it "returns the result of the c function directly" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v1"
    end
  end

  describe "for :struct" do
    before do
      stub(type_info).flattened_tag { :struct }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :union" do
    before do
      stub(type_info).flattened_tag { :union }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :interface" do
    before do
      stub(type_info).flattened_tag { :interface }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :object" do
    before do
      stub(type_info).flattened_tag { :object }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :strv" do
    before do
      stub(type_info).flattened_tag { :strv }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::Strv.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :zero_terminated" do
    before do
      stub(type_info).flattened_tag { :zero_terminated }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      # FIXME: This is almost certainly wrong, but matches original behavior.
      builder.post.must_equal [ "_v2 = GirFFI::InPointer.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :byte_array" do
    before do
      stub(type_info).flattened_tag { :byte_array }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::ByteArray.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :ptr_array" do
    before do
      stub(type_info).flattened_tag { :ptr_array }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::PtrArray.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :glist" do
    before do
      stub(type_info).flattened_tag { :glist }
      stub(type_info).element_type { :foo }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::List.wrap(:foo, _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end
end
