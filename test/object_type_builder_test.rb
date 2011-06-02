require File.expand_path('test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Type::Object do
  describe "building GObject::TypeModule, which implements an interface" do
    before do
      info = get_introspection_data 'GObject', 'TypeModule'
      @bldr = GirFFI::Builder::Type::Object.new info
    end

    it "mixes the interface into the generated class" do
      klass = @bldr.build_class
      assert_includes klass.ancestors, GObject::TypePlugin
    end
  end

  describe "building the CharsetConverter class" do
    before do
      GirFFI.setup :Gio
    end

    it "includes two interfaces" do
      klass = Gio::CharsetConverter
      assert_includes klass.ancestors, Gio::Converter
      assert_includes klass.ancestors, Gio::Initable
    end

    it "allows an instance to find the #reset method" do
      cnv = Gio::CharsetConverter.new "utf8", "utf8"
      cnv.reset
      pass
    end
  end
end

