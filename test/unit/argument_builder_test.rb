require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Argument::Base do
  describe "#subtype_tag" do
    it "returns :gpointer if the param_type is a pointer with tag :void" do
      stub(subtype0 = Object.new).tag { :void }
      stub(subtype0).pointer? { true }
      stub(type = Object.new).param_type(0) { subtype0 }

      provider = GirFFI::Builder::Argument::Base.new nil, nil, type

      assert_equal :gpointer, provider.subtype_tag
    end
  end

  describe "#subtype_tag_or_class_name" do
    describe "for a simple type" do
      it "returns the string ':void'" do
        mock(subtype = Object.new).tag { :void }
        mock(subtype).pointer? { false }

        mock(info = Object.new).param_type(0) { subtype }

        builder = GirFFI::Builder::Argument::Base.new nil, 'foo', info
        assert_equal ":void", builder.subtype_tag_or_class_name
      end
    end

    describe "for an array of simple type :foo" do
      it "returns the string ':foo'" do
        mock(subtype = Object.new).tag { :foo }
        mock(subtype).pointer? { false }

        mock(info = Object.new).param_type(0) { subtype }

        builder = GirFFI::Builder::Argument::Base.new nil, 'bar', info
        assert_equal ":foo", builder.subtype_tag_or_class_name
      end
    end

    describe "for an array of interface class Foo::Bar" do
      it "returns the string '::Foo::Bar'" do
        mock(interface = Object.new).safe_namespace { "Foo" }
        mock(interface).name { "Bar" }

        mock(subtype = Object.new).tag { :interface }
        mock(subtype).interface { interface }
        mock(subtype).pointer? { false }

        mock(info = Object.new).param_type(0) { subtype }

        builder = GirFFI::Builder::Argument::Base.new nil, 'bar', info
        assert_equal "::Foo::Bar", builder.subtype_tag_or_class_name
      end
    end

    describe "for an array of pointer to simple type :foo" do
      it "returns the string '[:pointer, :foo]'" do
        mock(subtype = Object.new).tag { :foo }
        mock(subtype).pointer? { true }

        mock(info = Object.new).param_type(0) { subtype }

        builder = GirFFI::Builder::Argument::Base.new nil, 'bar', info
        assert_equal "[:pointer, :foo]", builder.subtype_tag_or_class_name
      end
    end

  end
end

