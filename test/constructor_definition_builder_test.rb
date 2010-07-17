require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'girffi/builder'

class ConstructorDefinitionBuilderTest < Test::Unit::TestCase
  context "The ConstructorDefinitionBuilder" do
    should "build correct definition of Gtk::Window#new" do
      go = get_method_introspection_data 'Gtk', 'Window', 'new'
      cbuilder = GirFFI::ConstructorDefinitionBuilder.new go, Lib
      code = cbuilder.generate

      expected =
	"def new type
	  _real_new Lib.gtk_window_new(type)
	end"

      assert_equal cws(expected), cws(code)
    end
  end
end
