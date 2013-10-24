require 'gir_ffi_test_helper'

# Dummy module
module Bar
  module Foo

  end
end

# NOTE: All cooperating classes were originally stubbed, but this became
# unweildy as functionality was moved between classes. Also, IArgInfo and
# related classes are not really classes controlled by GirFFI, as part of their
# interface is dictated by GIR's implementation. Therefore, these tests are
# being converted to a situation where they test behavior agains real instances
# of IArgInfo.
describe GirFFI::Builders::ArgumentBuilder do
  let(:argument_info) { Object.new }
  let(:type_info) { Object.new }
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, argument_info) }
  let(:conversion_arguments) { [] }
  let(:argument_class_name) { nil }

  before do
    stub(argument_info).name { 'foo' }
    stub(argument_info).argument_type { type_info }
    stub(argument_info).direction { direction }
    stub(argument_info).skip? { false }
    stub(type_info).argument_class_name { argument_class_name }
    stub(type_info).extra_conversion_arguments { conversion_arguments }
  end

  describe "for an argument with direction :in" do
    let(:direction) { :in }

    describe "for :callback" do
      let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }
      let(:arg_info) {
        get_introspection_data('Regress', 'test_callback_destroy_notify').args[0] }

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = ::Regress::TestCallbackUserData.from(callback)" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ ]
      end
    end

    describe "for :zero_terminated" do
      let(:argument_class_name) { 'GirFFI::ZeroTerminated' }
      let(:conversion_arguments) { [:foo] }

      before do
        stub(type_info).flattened_tag { :zero_terminated }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::ZeroTerminated.from(:foo, foo)" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ ]
      end
    end
  end

  describe "for an argument with direction :out" do
    let(:direction) { :out }

    describe "for :enum" do
      let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }
      let(:arg_info) { get_introspection_data("GIMarshallingTests", "genum_out").args[0] }

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for GIMarshallingTests::GEnum" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = _v1.to_value" ]
      end
    end

    describe "for :flags" do
      let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }
      let(:arg_info) {
        get_introspection_data("GIMarshallingTests", "flags_out").args[0] }

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for GIMarshallingTests::Flags" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = _v1.to_value" ]
      end
    end

    describe "for :object" do
      let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }
      let(:arg_info) {
        get_method_introspection_data("Regress", "TestObj", "null_out").args[0] }

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:pointer, Regress::TestObj]" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = ::Regress::TestObj.wrap(_v1.to_value)" ]
      end
    end

    describe "for :struct" do
      let(:argument_class_name) { 'Bar::Foo' }
      before do
        stub(type_info).flattened_tag { :struct }
      end

      describe "when not allocated by the caller" do
        let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }
        let(:arg_info) {
          get_introspection_data("GIMarshallingTests", "boxed_struct_out").args[0] }

        it "has the correct value for #pre" do
          builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:pointer, GIMarshallingTests::BoxedStruct]" ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = ::GIMarshallingTests::BoxedStruct.wrap(_v1.to_value)" ]
        end
      end

      describe "when allocated by the caller" do
        before do
          stub(argument_info).caller_allocates? { true }
        end

        it "has the correct value for #pre" do
          builder.pre.must_equal [ "_v1 = Bar::Foo.new" ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = _v1" ]
        end
      end
    end

    describe "for :strv" do
      let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }
      let(:arg_info) {
        get_introspection_data("GIMarshallingTests", "gstrv_out").args[0] }

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:pointer, :strv]" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::Strv.wrap(_v1.to_value)" ]
      end
    end

    describe "for :array" do
      let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }

      describe "when allocated by the callee" do
        let(:arg_info) {
          get_introspection_data("GIMarshallingTests", "garray_utf8_none_out").args[0] }

        it "has the correct value for #pre" do
          builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:pointer, :array]" ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = GLib::Array.wrap(:utf8, _v1.to_value)" ]
        end
      end

      describe "when allocated by the caller" do
        let(:arg_info) {
          get_introspection_data("GIMarshallingTests", "garray_utf8_full_out_caller_allocated").args[0] }

          before do
            # FIXME: Find alternative info that doesn't need a guard.
            skip unless get_introspection_data("GIMarshallingTests", "garray_utf8_full_out_caller_allocated")
          end

        it "has the correct value for #pre" do
          builder.pre.must_equal [ "_v1 = GLib::Array.new :utf8" ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = _v1" ]
        end
      end
    end

    describe "for :ptr_array" do
      let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }
      let(:arg_info) {
        get_introspection_data("GIMarshallingTests", "gptrarray_utf8_none_out").args[0] }

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:pointer, :ptr_array]" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::PtrArray.wrap(:utf8, _v1.to_value)" ]
      end
    end

    describe "for :error" do
      let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }
      let(:arg_info) {
        get_introspection_data("GIMarshallingTests", "gerror_out").args[0] }

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:pointer, :error]" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::Error.wrap(_v1.to_value)" ]
      end
    end

    describe "for :c" do
      let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }

      describe "with fixed size" do
        let(:arg_info) {
          get_introspection_data("GIMarshallingTests", "array_fixed_out").args[0] }

        it "has the correct value for #pre" do
          builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:pointer, :c]" ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = GirFFI::SizedArray.wrap(:gint32, 4, _v1.to_value)" ]
        end
      end

      describe "with separate size parameter" do
        let(:arg_info) {
          get_introspection_data("GIMarshallingTests", "array_out").args[0] }

        let(:length_argument) { Object.new }
        before do
          stub(length_argument).retname { "bar" }
          builder.length_arg = length_argument
        end

        it "has the correct value for #pre" do
          builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:pointer, :c]" ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = GirFFI::SizedArray.wrap(:gint32, bar, _v1.to_value)" ]
        end
      end
    end

    describe "for :glist" do
      let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }
      let(:arg_info) {
        get_introspection_data("GIMarshallingTests", "glist_utf8_none_out").args[0] }

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:pointer, :glist]" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::List.wrap(:utf8, _v1.to_value)" ]
      end
    end

    describe "for :gslist" do
      let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }
      let(:arg_info) {
        get_introspection_data("GIMarshallingTests", "gslist_utf8_none_out").args[0] }

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:pointer, :gslist]" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::SList.wrap(:utf8, _v1.to_value)" ]
      end
    end

    describe "for :ghash" do
      let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }
      let(:arg_info) {
        get_introspection_data("GIMarshallingTests", "ghashtable_utf8_none_out").args[0] }

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:pointer, :ghash]" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::HashTable.wrap([:utf8, :utf8], _v1.to_value)" ]
      end
    end
  end

  describe "for an argument with direction :inout" do
    let(:direction) { :inout }

    describe "for :enum" do
      let(:argument_class_name) { 'Bar::Foo' }
      before do
        stub(type_info).flattened_tag { :enum }
        stub(type_info).tag_or_class { Bar::Foo }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.from Bar::Foo, foo" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = _v1.to_value" ]
      end
    end

    describe "for :flags" do
      let(:argument_class_name) { 'Bar::Foo' }
      before do
        stub(type_info).flattened_tag { :flags }
        stub(type_info).tag_or_class { Bar::Foo }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.from Bar::Foo, foo" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = _v1.to_value" ]
      end
    end

    describe "for :gint32" do
      before do
        stub(type_info).flattened_tag { :gint32 }
        stub(type_info).tag_or_class { :gint32 }
      end

      it "has the correct value for inarg" do
        builder.inarg.must_equal "foo"
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.from :gint32, foo" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = _v1.to_value" ]
      end
    end

    describe "for an array length" do
      let(:function_info) {
        get_introspection_data('Regress', 'test_array_int_inout') }
      let(:arg_info) { function_info.args[0] }
      let(:array_arg_info) { function_info.args[1] }
      let(:builder) {
        GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }
      let(:array_arg_builder) {
        GirFFI::Builders::ArgumentBuilder.new(var_gen, array_arg_info) }

      before do
        builder.array_arg = array_arg_builder
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "n_ints = ints.nil? ? 0 : ints.length",
                                 "_v1 = GirFFI::InOutPointer.from :gint32, n_ints" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = _v1.to_value" ]
      end
    end

    describe "for :strv" do
      let(:argument_class_name) { 'GLib::Strv' }
      before do
        stub(type_info).flattened_tag { :strv }
        stub(type_info).tag_or_class { [:pointer, :array] }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.from [:pointer, :array], GLib::Strv.from(foo)" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::Strv.wrap(_v1.to_value)" ]
      end
    end

    describe "for :ptr_array" do
      let(:conversion_arguments) { [:foo] }
      let(:argument_class_name) { 'GLib::PtrArray' }

      before do
        stub(type_info).flattened_tag { :ptr_array }
        stub(type_info).tag_or_class { [:pointer, :array] }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.from [:pointer, :array], GLib::PtrArray.from(:foo, foo)" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::PtrArray.wrap(:foo, _v1.to_value)" ]
      end
    end

    describe "for :utf8" do
      let(:conversion_arguments) { [:utf8] }
      let(:argument_class_name) { 'GirFFI::InPointer' }

      before do
        stub(type_info).flattened_tag { :utf8 }
        stub(type_info).tag_or_class { :utf8 }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.from :utf8, GirFFI::InPointer.from(:utf8, foo)" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = _v1.to_value.to_utf8" ]
      end
    end

    describe "for :c" do
      let(:argument_class_name) { 'GirFFI::SizedArray' }

      before do
        stub(type_info).flattened_tag { :c }
        stub(type_info).tag_or_class { [:pointer, :c] }
        stub(type_info).subtype_tag_or_class { :bar }
      end

      describe "with fixed size" do
        let(:conversion_arguments) { [:bar, 3] }

        before do
          stub(type_info).array_fixed_size { 3 }
        end

        it "has the correct value for #pre" do
          builder.pre.must_equal [
            "GirFFI::ArgHelper.check_fixed_array_size 3, foo, \"foo\"",
            "_v1 = GirFFI::InOutPointer.from [:pointer, :c], GirFFI::SizedArray.from(:bar, 3, foo)"
          ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = GirFFI::SizedArray.wrap(:bar, 3, _v1.to_value)" ]
        end
      end

      describe "with separate size parameter" do
        let(:length_argument) { Object.new }
        let(:conversion_arguments) { [:bar, -1] }
        before do
          stub(type_info).array_fixed_size { -1 }
          stub(length_argument).retname { "baz" }
          builder.length_arg = length_argument
        end

        it "has the correct value for #pre" do
          builder.pre.must_equal [
            "_v1 = GirFFI::InOutPointer.from [:pointer, :c], GirFFI::SizedArray.from(:bar, -1, foo)"
          ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = GirFFI::SizedArray.wrap(:bar, baz, _v1.to_value)" ]
        end
      end
    end
  end

  describe "for a skipped argument with direction :in" do
    let(:direction) { :in }

    before do
      stub(argument_info).skip? { true }
    end

    describe "for :gint32" do
      before do
        stub(type_info).flattened_tag { :gint32 }
      end

      it "has the correct value for inarg" do
        builder.inarg.must_be_nil
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = 0" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal []
      end
    end
  end

  describe "for a skipped argument with direction :inout" do
    let(:direction) { :inout }

    before do
      stub(argument_info).skip? { true }
    end

    describe "for :gint32" do
      before do
        stub(type_info).flattened_tag { :gint32 }
      end

      it "has the correct value for inarg" do
        builder.inarg.must_be_nil
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = nil" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal []
      end
    end
  end

  describe "for a skipped argument with direction :out" do
    let(:direction) { :out }

    before do
      stub(argument_info).skip? { true }
    end

    describe "for :gint32" do
      before do
        stub(type_info).flattened_tag { :gint32 }
      end

      it "has the correct value for inarg" do
        builder.inarg.must_be_nil
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = nil" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal []
      end
    end
  end
end
