require 'gir_ffi_test_helper'

describe GirFFI::Builder::RegularArgument do
  let(:type_info) { Object.new }
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:builder) { GirFFI::Builder::RegularArgument.new(var_gen, 'foo',
                                                       type_info, direction) }

  before do
    stub(type_info).interface_type_name { 'Bar::Foo' }
  end

  describe "for an argument with direction :out" do
    let(:direction) { :out }

    describe "for :enum" do
      before do
        stub(type_info).tag { :interface }
        stub(type_info).flattened_tag { :enum }
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
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for :object" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1.to_value)" ]
      end
    end

    describe "for :struct" do
      before do
        stub(type_info).tag { :interface }
        stub(type_info).flattened_tag { :struct }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for :struct" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1.to_value)" ]
      end
    end

    describe "for :strv" do
      before do
        stub(type_info).tag { :array }
        stub(type_info).flattened_tag { :strv }
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for :strv" ]
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
      end

      it "has the correct value for #pre" do
        builder.pre.must_equal [ "_v1 = GirFFI::InOutPointer.for :array" ]
      end

      it "has the correct value for #post" do
        builder.post.must_equal [ "_v2 = GLib::Array.wrap(:foo, _v1.to_value)" ]
      end
    end

    describe "for :glist" do
      before do
        stub(type_info).tag { :glist }
        stub(type_info).flattened_tag { :glist }
        stub(type_info).element_type { :foo }
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
  end
end

