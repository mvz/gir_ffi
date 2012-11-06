require 'gir_ffi_test_helper'

describe GirFFI::Builder::RegularArgument do
  describe "for an argument with direction :out" do
    let(:var_gen) { GirFFI::VariableNameGenerator.new }
    let(:type_info) { Object.new }
    let(:builder) { GirFFI::Builder::RegularArgument.new var_gen, 'foo', type_info, :out }

    before do
      stub(type_info).interface_type_name { 'Bar::Foo' }
    end

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

  end
end

