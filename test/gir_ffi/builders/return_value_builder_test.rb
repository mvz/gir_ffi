require 'gir_ffi_test_helper'

describe GirFFI::Builders::ReturnValueBuilder do
  let(:type_info) { Object.new }
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:for_constructor) { false }
  let(:skip) { false }
  let(:builder) { GirFFI::Builders::ReturnValueBuilder.new(var_gen,
                                                 type_info,
                                                 for_constructor,
                                                 skip) }
  let(:conversion_arguments) { [] }
  let(:argument_class_name) { flattened_tag }
  let(:flattened_tag) { nil }

  before do
    stub(type_info).argument_class_name { argument_class_name }
    stub(type_info).extra_conversion_arguments { conversion_arguments }
    stub(type_info).flattened_tag { flattened_tag }
  end

  describe "for :gint32" do
    let(:flattened_tag) { :gint32 }

    it "has no statements in #post" do
      builder.post.must_equal []
    end

    it "returns the result of the c function directly" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v1"
    end
  end

  describe "for :struct" do
    let(:argument_class_name) { 'Bar::Foo' }
    let(:flattened_tag) { :struct }

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
    let(:argument_class_name) { 'Bar::Foo' }
    let(:flattened_tag) { :union }

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
    let(:argument_class_name) { 'Bar::Foo' }
    let(:flattened_tag) { :interface }

    describe "when the method is not a constructor" do
      let(:for_constructor) { false }

      it "wraps the result in #post" do
        builder.callarg.must_equal "_v1"
        builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1)" ]
      end

      it "returns the wrapped result" do
        builder.callarg.must_equal "_v1"
        builder.retval.must_equal "_v2"
      end
    end

    describe "when the method is a constructor" do
      let(:for_constructor) { true }

      it "wraps the result in #post" do
        builder.callarg.must_equal "_v1"
        builder.post.must_equal [ "_v2 = self.constructor_wrap(_v1)" ]
      end

      it "returns the wrapped result" do
        builder.callarg.must_equal "_v1"
        builder.retval.must_equal "_v2"
      end
    end
  end

  describe "for :object" do
    let(:argument_class_name) { 'Bar::Foo' }
    let(:flattened_tag) { :object }

    describe "when the method is not a constructor" do
      let(:for_constructor) { false }

      it "wraps the result in #post" do
        builder.callarg.must_equal "_v1"
        builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1)" ]
      end

      it "returns the wrapped result" do
        builder.callarg.must_equal "_v1"
        builder.retval.must_equal "_v2"
      end
    end

    describe "when the method is a constructor" do
      let(:for_constructor) { true }

      it "wraps the result in #post" do
        builder.callarg.must_equal "_v1"
        builder.post.must_equal [ "_v2 = self.constructor_wrap(_v1)" ]
      end

      it "returns the wrapped result" do
        builder.callarg.must_equal "_v1"
        builder.retval.must_equal "_v2"
      end
    end
  end

  describe "for :strv" do
    let(:argument_class_name) { 'GLib::Strv' }
    let(:flattened_tag) { :strv }

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
    let(:argument_class_name) { 'GirFFI::ZeroTerminated' }
    let(:conversion_arguments) { [:foo] }
    let(:flattened_tag) { :zero_terminated }

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GirFFI::ZeroTerminated.wrap(:foo, _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :byte_array" do
    let(:argument_class_name) { 'GLib::ByteArray' }
    let(:flattened_tag) { :byte_array }

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
    let(:argument_class_name) { 'GLib::PtrArray' }
    let(:conversion_arguments) { [:foo] }
    let(:flattened_tag) { :ptr_array }

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::PtrArray.wrap(:foo, _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :glist" do
    let(:argument_class_name) { 'GLib::List' }
    let(:conversion_arguments) { [:foo] }
    let(:flattened_tag) { :glist }

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::List.wrap(:foo, _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :gslist" do
    let(:argument_class_name) { 'GLib::SList' }
    let(:conversion_arguments) { [:foo] }
    let(:flattened_tag) { :gslist }

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::SList.wrap(:foo, _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :ghash" do
    let(:argument_class_name) { 'GLib::HashTable' }
    let(:conversion_arguments) { [[:foo, :bar]] }
    let(:flattened_tag) { :ghash }

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::HashTable.wrap([:foo, :bar], _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :array" do
    let(:argument_class_name) { 'GLib::Array' }
    let(:conversion_arguments) { [:foo] }
    let(:flattened_tag) { :array }

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::Array.wrap(:foo, _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :error" do
    let(:argument_class_name) { 'GLib::Error' }
    let(:flattened_tag) { :error }

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::Error.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :c" do
    let(:argument_class_name) { 'GLib::SizedArray' }

    describe "with fixed size" do
      before do
        stub(type_info).flattened_tag { :c }
        stub(type_info).subtype_tag_or_class { :foo }
        stub(type_info).array_fixed_size { 3 }
      end

      it "converts the result in #post" do
        builder.callarg.must_equal "_v1"
        builder.post.must_equal [ "_v2 = GLib::SizedArray.wrap(:foo, 3, _v1)" ]
      end

      it "returns the wrapped result" do
        builder.callarg.must_equal "_v1"
        builder.retval.must_equal "_v2"
      end
    end

    describe "with separate size parameter" do
      let(:length_argument) { Object.new }

      before do
        stub(type_info).flattened_tag { :c }
        stub(type_info).subtype_tag_or_class { :foo }
        stub(type_info).array_fixed_size { -1 }

        stub(length_argument).retname { "bar" }
        builder.length_arg = length_argument
      end

      it "converts the result in #post" do
        builder.callarg.must_equal "_v1"
        builder.post.must_equal [ "_v2 = GLib::SizedArray.wrap(:foo, bar, _v1)" ]
      end

      it "returns the wrapped result" do
        builder.callarg.must_equal "_v1"
        builder.retval.must_equal "_v2"
      end
    end
  end

  describe "for :utf8" do
    before do
      stub(type_info).flattened_tag { :utf8 }
    end

    it "converts the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = _v1.to_utf8" ]
    end

    it "returns the converted result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :void pointer" do
    before do
      stub(type_info).flattened_tag { :void }
      stub(type_info).pointer? { true }
    end

    it "has no statements in #post" do
      builder.post.must_equal []
    end

    it "returns the result of the c function directly" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v1"
    end
  end

  describe "for :void" do
    before do
      stub(type_info).flattened_tag { :void }
      stub(type_info).pointer? { false }
    end

    it "has no statements in #post" do
      builder.post.must_equal []
    end

    it "marks itself as irrelevant" do
      builder.is_relevant?.must_equal false
    end

    it "returns nothing" do
      builder.retval.must_be_nil
    end
  end

  describe "for a closure argument" do
    let(:tp_info) {
      get_introspection_data("Regress", "TestCallbackUserData").args[0].argument_type }
    let(:builder) { GirFFI::Builders::ReturnValueBuilder.new(var_gen, tp_info) }

    before do
      builder.is_closure = true
    end

    it "fetches the stored object in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GirFFI::ArgHelper::OBJECT_STORE[_v1.address]" ]
    end

    it "returns the stored object" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for a skipped return value" do
    let(:skip) { true }

    before do
      stub(type_info).flattened_tag { :uint32 }
      stub(type_info).pointer? { false }
    end

    it "has no statements in #post" do
      builder.post.must_equal []
    end

    it "marks itself as irrelevant" do
      builder.is_relevant?.must_equal false
    end

    it "returns nothing" do
      builder.retval.must_be_nil
    end
  end
end
