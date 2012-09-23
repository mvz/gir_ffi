require 'gir_ffi_test_helper'

describe GirFFI::Builder::Argument::Base do
  describe "#subtype_tag_or_class_name" do
    describe "for a simple type" do
      it "returns the string ':void'" do
        mock(subtype = Object.new).tag { :void }
        mock(subtype).pointer? { false }

        mock(info = Object.new).param_type(0) { subtype }

        builder = GirFFI::Builder::Argument::Base.new nil, 'foo', info, :direction
        assert_equal ":void", builder.subtype_tag_or_class_name
      end
    end

    describe "for an array of simple type :foo" do
      it "returns the string ':foo'" do
        mock(subtype = Object.new).tag { :foo }
        mock(subtype).pointer? { false }

        mock(info = Object.new).param_type(0) { subtype }

        builder = GirFFI::Builder::Argument::Base.new nil, 'bar', info, :direction
        assert_equal ":foo", builder.subtype_tag_or_class_name
      end
    end

    describe "for an array of an interface class" do
      it "returns the interface's full class name" do
        mock(subtype = Object.new).tag { :interface }
        mock(subtype).interface_type_name { "-full-type-name-" }
        mock(subtype).pointer? { false }

        mock(info = Object.new).param_type(0) { subtype }

        builder = GirFFI::Builder::Argument::Base.new nil, 'bar', info, :direction
        assert_equal "-full-type-name-", builder.subtype_tag_or_class_name
      end
    end

    describe "for an array of pointer to simple type :foo" do
      it "returns the string '[:pointer, :foo]'" do
        mock(subtype = Object.new).tag { :foo }
        mock(subtype).pointer? { true }

        mock(info = Object.new).param_type(0) { subtype }

        builder = GirFFI::Builder::Argument::Base.new nil, 'bar', info, :direction
        assert_equal "[:pointer, :foo]", builder.subtype_tag_or_class_name
      end
    end

  end
end

