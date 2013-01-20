require 'gir_ffi_test_helper'

describe GirFFI::ArgumentBuilder do
  let(:argument_info) { Object.new }
  let(:type_info) { Object.new }
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:builder) { GirFFI::ArgumentBuilder.new(var_gen, argument_info) }

  before do
    stub(argument_info).name { 'foo' }
    stub(argument_info).argument_type { type_info }
    stub(argument_info).direction { direction }
    stub(type_info).interface_type_name { 'Bar::Foo' }
  end

  describe "for an argument with direction :in" do
    let(:direction) { :in }

    describe "for :callback" do
      before do
        stub(interface_type_info = Object.new).namespace { "Bar" }
        stub(interface_type_info).name { "Foo" }

        stub(type_info).tag { :interface }
        stub(type_info).flattened_tag { :callback }
        stub(type_info).type_specification { ":callback" }
        stub(type_info).interface { interface_type_info }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::Callback.from(\"Bar\", \"Foo\", foo)" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ ]
      end
    end

    describe "for :zero_terminated" do
      before do
        stub(type_info).tag { :array }
        stub(type_info).flattened_tag { :zero_terminated }
        stub(type_info).element_type { :foo }
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
      before do
        stub(type_info).tag { :interface }
        stub(type_info).flattened_tag { :enum }
        stub(type_info).type_specification { ":enum" }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for :enum" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = Bar::Foo[_v1.to_value]" ]
      end
    end

    describe "for :flags" do
      before do
        stub(type_info).tag { :interface }
        stub(type_info).flattened_tag { :flags }
        stub(type_info).type_specification { ":flags" }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for :flags" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = Bar::Foo[_v1.to_value]" ]
      end
    end

    describe "for :object" do
      before do
        stub(type_info).tag { :interface }
        stub(type_info).flattened_tag { :object }
        stub(type_info).type_specification { ":object" }
      end

      describe "when not allocated by the caller" do
        before do
          stub(argument_info).caller_allocates? { false }
        end

        it "has the correct value for #pre" do
          builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for :object" ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1.to_value)" ]
        end
      end

      describe "when allocated by the caller" do
        before do
          stub(argument_info).caller_allocates? { true }
        end

        it "has the correct value for #pre" do
          builder.pre.must_equal [ "_v1 = Bar::Foo.allocate" ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = _v1" ]
        end
      end
    end

    describe "for :struct" do
      before do
        stub(type_info).tag { :interface }
        stub(type_info).flattened_tag { :struct }
        stub(type_info).type_specification { ":struct" }
      end

      describe "when not allocated by the caller" do
        before do
          stub(argument_info).caller_allocates? { false }
        end

        it "has the correct value for #pre" do
          builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for :struct" ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1.to_value)" ]
        end
      end

      describe "when allocated by the caller" do
        before do
          stub(argument_info).caller_allocates? { true }
        end

        it "has the correct value for #pre" do
          builder.pre.must_equal [ "_v1 = Bar::Foo.allocate" ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = _v1" ]
        end
      end
    end

    describe "for :strv" do
      before do
        stub(type_info).tag { :array }
        stub(type_info).flattened_tag { :strv }
        stub(type_info).type_specification { "[:strv, :utf8]" }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:strv, :utf8]" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::Strv.wrap(_v1.to_value)" ]
      end
    end

    describe "for :array" do
      before do
        stub(type_info).tag { :array }
        stub(type_info).flattened_tag { :array }
        stub(type_info).element_type { :foo }
        stub(type_info).type_specification { ":array" }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for :array" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::Array.wrap(:foo, _v1.to_value)" ]
      end
    end

    describe "for :c" do
      describe "with fixed size" do
        before do
          stub(type_info).tag { :array }
          stub(type_info).flattened_tag { :c }
          stub(type_info).type_specification { "[:c, :foo]" }
          stub(type_info).array_fixed_size { 3 }
        end

        it "has the correct value for #pre" do
          builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:c, :foo]" ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = _v1.to_sized_array_value 3" ]
        end
      end

      describe "with separate size parameter" do
        let(:length_argument) { Object.new }
        before do
          stub(type_info).tag { :array }
          stub(type_info).flattened_tag { :c }
          stub(type_info).type_specification { "[:c, :foo]" }
          stub(type_info).array_fixed_size { -1 }
          stub(length_argument).retname { "bar" }
          builder.length_arg = length_argument
        end

        it "has the correct value for #pre" do
          builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for [:c, :foo]" ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = _v1.to_sized_array_value bar" ]
        end
      end
    end

    describe "for :glist" do
      before do
        stub(type_info).tag { :glist }
        stub(type_info).flattened_tag { :glist }
        stub(type_info).element_type { :foo }
        stub(type_info).type_specification { ":glist" }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for :glist" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::List.wrap(:foo, _v1.to_value)" ]
      end
    end

    describe "for :gslist" do
      before do
        stub(type_info).tag { :gslist }
        stub(type_info).flattened_tag { :gslist }
        stub(type_info).element_type { :foo }
        stub(type_info).type_specification { ":gslist" }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for :gslist" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::SList.wrap(:foo, _v1.to_value)" ]
      end
    end

    describe "for :ghash" do
      before do
        stub(type_info).tag { :ghash }
        stub(type_info).flattened_tag { :ghash }
        stub(type_info).element_type { [:foo, :bar] }
        stub(type_info).type_specification { ":ghash" }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for :ghash" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::HashTable.wrap([:foo, :bar], _v1.to_value)" ]
      end
    end
  end

  describe "for an argument with direction :inout" do
    let(:direction) { :inout }

    describe "for :enum" do
      before do
        stub(type_info).tag { :interface }
        stub(type_info).flattened_tag { :enum }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.from :enum, Bar::Foo[foo]" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = Bar::Foo[_v1.to_value]" ]
      end
    end

    describe "for :flags" do
      before do
        stub(type_info).tag { :interface }
        stub(type_info).flattened_tag { :flags }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.from :flags, Bar::Foo[foo]" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = Bar::Foo[_v1.to_value]" ]
      end
    end

    describe "for :gint32" do
      before do
        stub(type_info).tag { :gint32 }
        stub(type_info).flattened_tag { :gint32 }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.from :gint32, foo" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = _v1.to_value" ]
      end
    end

    describe "for an array length" do
      let(:array_argument) { Object.new }
      before do
        stub(type_info).tag { :gint32 }
        stub(type_info).flattened_tag { :gint32 }
        stub(array_argument).name { "foo_array" }
        builder.array_arg = array_argument
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "foo = foo_array.nil? ? 0 : foo_array.length",
                                 "_v1 = GirFFI::InOutPointer.from :gint32, foo" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = _v1.to_value" ]
      end
    end

    describe "for :strv" do
      before do
        stub(type_info).tag { :array }
        stub(type_info).flattened_tag { :strv }
        stub(type_info).type_specification { "[:strv, :utf8]" }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.from [:strv, :utf8], GLib::Strv.from(foo)" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::Strv.wrap(_v1.to_value)" ]
      end
    end

    describe "for :utf8" do
      before do
        stub(type_info).tag { :utf8 }
        stub(type_info).flattened_tag { :utf8 }
        stub(type_info).type_specification { ":utf8" }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.from :utf8, foo" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = _v1.to_value" ]
      end
    end

    describe "for :c" do
      describe "with fixed size" do
        before do
          stub(type_info).tag { :array }
          stub(type_info).flattened_tag { :c }
          stub(type_info).type_specification { "[:c, :bar]" }
          stub(type_info).array_fixed_size { 3 }
        end

        it "has the correct value for #pre" do
          builder.pre.must_equal [
            "GirFFI::ArgHelper.check_fixed_array_size 3, foo, \"foo\"",
            "_v1 = GirFFI::InOutPointer.from [:c, :bar], foo"
          ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = _v1.to_sized_array_value 3" ]
        end
      end

      describe "with separate size parameter" do
        let(:length_argument) { Object.new }
        before do
          stub(type_info).tag { :array }
          stub(type_info).flattened_tag { :c }
          stub(type_info).type_specification { "[:c, :bar]" }
          stub(type_info).array_fixed_size { -1 }
          stub(length_argument).retname { "baz" }
          builder.length_arg = length_argument
        end

        it "has the correct value for #pre" do
          # TODO: Perhaps this should include a length check as well.
          builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.from [:c, :bar], foo" ]
        end

        it "has the correct value for #post" do
          builder.post.must_equal [ "_v2 = _v1.to_sized_array_value baz" ]
        end
      end
    end
  end
end

