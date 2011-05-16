require File.expand_path('test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Type::Object do
  describe "building GObject::TypeModule, which implements an interface" do
    before do
      info = get_function_introspection_data 'GObject', 'TypeModule'
      @bldr = GirFFI::Builder::Type::Object.new info
    end

    it "mixes the interface into the generated class" do
      klass = @bldr.build_class
      assert_includes klass.ancestors, GObject::TypePlugin
    end
  end
end

