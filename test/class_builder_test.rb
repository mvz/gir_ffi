require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi'

class ClassBuilderTest < Test::Unit::TestCase
  context "The ClassBuilder" do
    setup do
      @gir = GirFFI::IRepository.default
      @gir.require 'GObject', nil
    end
    should "use parent struct as default layout" do
      @classbuilder = GirFFI::ClassBuilder.new 'Foo', 'Bar'
      stub(info = Object.new).parent { @gir.find_by_name 'GObject', 'Object' }
      stub(info).fields { [] }
      @classbuilder.instance_eval { @info = info }
      @classbuilder.instance_eval { @parent = info.parent }
      @classbuilder.instance_eval { @superclass = GObject::Object }

      spec = @classbuilder.send :layout_specification
      assert_equal [:parent, GObject::Object::Struct, 0], spec
    end
  end
end

