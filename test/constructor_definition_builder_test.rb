require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'girffi/builder'

class ConstructorDefinitionBuilderTest < Test::Unit::TestCase
  context "The ConstructorDefinitionBuilder" do
    setup do
      @builder = GirFFI::Builder.new
    end

    should "build correct definition of Gtk::Window#initialize" do
      go = @builder.method_introspection_data 'Gtk', 'Window', 'new'
      cbuilder = GirFFI::ConstructorDefinitionBuilder.new go
      code = cbuilder.generate

      expected =
	"def initialize type
	  @gobj = Lib.gtk_window_new type
	end"

      assert_equal cws(expected), cws(code)
    end
  end
end
