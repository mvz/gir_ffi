require File.expand_path('gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'ffi-gtk3'

class TypeBuilderTest < MiniTest::Spec
  context "The Builder::Type class" do
    context 'the find_signal method' do
      should 'find the signal "test" for TestObj' do
	builder = GirFFI::Builder::Type::Object.new get_introspection_data('Regress', 'TestObj')
	sig = builder.find_signal 'test'
	assert_equal 'test', sig.name
      end

      should 'find the signal "test" for TestSubObj' do
	builder = GirFFI::Builder::Type::Object.new get_introspection_data('Regress', 'TestSubObj')
	sig = builder.find_signal 'test'
	assert_equal 'test', sig.name
      end

      should 'find the signal "changed" for Gtk::Entry' do
	builder = GirFFI::Builder::Type::Object.new get_introspection_data('Gtk', 'Entry')
	sig = builder.find_signal 'changed'
	assert_equal 'changed', sig.name
      end
    end

    context "for GObject::TypeCValue (a union)" do
      setup do
	@cbuilder = GirFFI::Builder::Type::Union.new get_introspection_data('GObject', 'TypeCValue')
      end

      should "returns false looking for a method that doesn't exist" do
	assert_equal false, @cbuilder.setup_instance_method('blub')
      end
    end
  end
end

