require File.expand_path('test_helper.rb', File.dirname(__FILE__))

class TypeBuilderTest < Test::Unit::TestCase
  context "The Builder::Type class" do
    setup do
      @gir = GirFFI::IRepository.default
    end

    should "use parent struct as default layout" do
      @gir.require 'GObject', nil

      stub(info = Object.new).parent { @gir.find_by_name 'GObject', 'Object' }
      stub(info).fields { [] }
      stub(info).type { :object }
      stub(info).name { 'Bar' }
      stub(info).namespace { 'Foo' }

      @classbuilder = GirFFI::Builder::Type.new info

      spec = @classbuilder.send :layout_specification
      assert_equal [:parent, GObject::Object::Struct, 0], spec
    end

    context "for Gtk::Widget" do
      setup do
	@cbuilder = GirFFI::Builder::Type.new @gir.find_by_name('Gtk', 'Widget')
      end

      context "looking at Gtk::Widget#show" do
	setup do
	  @go = get_method_introspection_data 'Gtk', 'Widget', 'show'
	end

	should "delegate definition to Builder::Function" do
	  code = @cbuilder.send :function_definition, @go
	  expected = GirFFI::Builder::Function.new(@go, Gtk::Lib).generate
	  assert_equal cws(expected), cws(code)
	end

      end
    end

    context 'the find_signal method' do
      should 'find the signal "test" for TestObj' do
	builder = GirFFI::Builder::Type.new @gir.find_by_name('Regress', 'TestObj')
	sig = builder.find_signal 'test'
	assert_equal 'test', sig.name
      end

      should 'find the signal "test" for TestSubObj' do
	builder = GirFFI::Builder::Type.new @gir.find_by_name('Regress', 'TestSubObj')
	sig = builder.find_signal 'test'
	assert_equal 'test', sig.name
      end

      should 'find the signal "changed" for Gtk::Entry' do
	builder = GirFFI::Builder::Type.new @gir.find_by_name('Gtk', 'Entry')
	sig = builder.find_signal 'changed'
	assert_equal 'changed', sig.name
      end
    end

    context "for GObject::TypeCValue (a union)" do
      setup do
	@cbuilder = GirFFI::Builder::Type.new @gir.find_by_name('GObject', 'TypeCValue')
      end

      should "not raise an error looking for a method that doesn't exist" do
	assert_nothing_raised { @cbuilder.setup_instance_method 'blub' }
      end
    end
  end
end

