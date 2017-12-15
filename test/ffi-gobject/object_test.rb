# frozen_string_literal: true

require 'gir_ffi_test_helper'

require 'ffi-gobject'
GirFFI.setup :GIMarshallingTests

describe GObject::Object do
  describe '.new' do
    it 'is overridden to take only one argument' do
      GObject::Object.new({}).must_be_instance_of GObject::Object
    end

    it 'can be used to create objects with properties' do
      obj = GIMarshallingTests::SubObject.new(int: 13)
      obj.int.must_equal 13
    end

    it 'allows omission of the first argument' do
      GObject::Object.new.must_be_instance_of GObject::Object
    end

    it 'raises an error for properties that do not exist' do
      proc { GObject::Object.new(dog: 'bark') }.must_raise GirFFI::PropertyNotFoundError
    end
  end

  describe '#get_property' do
    it 'is overridden to have arity 1' do
      GObject::Object.instance_method('get_property').arity.must_equal 1
    end

    it 'raises an error for a property that does not exist' do
      instance = GObject::Object.new
      proc { instance.get_property 'foo-bar' }.must_raise GirFFI::PropertyNotFoundError
    end
  end

  describe '#get_property_extended' do
    it 'raises an error for a property that does not exist' do
      instance = GObject::Object.new
      proc { instance.get_property_extended 'foo-bar' }.
        must_raise GirFFI::PropertyNotFoundError
    end
  end

  describe '#set_property' do
    it 'raises an error for a property that does not exist' do
      instance = GObject::Object.new
      proc { instance.set_property 'foo-bar', 123 }.must_raise GirFFI::PropertyNotFoundError
    end
  end

  describe '#set_property_extended' do
    it 'raises an error for a property that does not exist' do
      instance = GObject::Object.new
      proc { instance.set_property_extended 'foo-bar', 123 }.
        must_raise GirFFI::PropertyNotFoundError
    end
  end

  describe 'automatic accessor methods' do
    class AccessorTest < GObject::Object
      def get_x
        @x
      end

      def set_x(val)
        @x = val
      end
    end

    subject { AccessorTest.new }

    it 'reads x by calling get_x' do
      subject.set_x(1)
      assert_equal 1, subject.x
    end

    it 'writes x by calling set_x' do
      subject.x = 2
      assert_equal 2, subject.x
    end
  end

  describe '#signal_connect' do
    subject { GObject::Object.new }

    it 'delegates to GObject' do
      expect(GObject).to receive(:signal_connect).with(subject, 'some-event', nil)
      subject.signal_connect('some-event') do
        nothing
      end
    end

    it 'delegates to GObject if an optional data argument is passed' do
      expect(GObject).to receive(:signal_connect).with(subject, 'some-event', 'data')
      subject.signal_connect('some-event', 'data') do
        nothing
      end
    end
  end

  describe '#signal_connect_after' do
    subject { GObject::Object.new }

    it 'delegates to GObject' do
      expect(GObject).to receive(:signal_connect_after).with(subject, 'some-event', nil)
      subject.signal_connect_after('some-event') do
        nothing
      end
    end

    it 'delegates to GObject if an optional data argument is passed' do
      expect(GObject).to receive(:signal_connect_after).with(subject, 'some-event', 'data')
      subject.signal_connect_after('some-event', 'data') do
        nothing
      end
    end
  end

  describe 'upon garbage collection' do
    it 'lowers the reference count' do
      skip 'cannot be reliably tested on JRuby and Rubinius' if jruby? || rubinius?

      ptr = GObject::Object.new.to_ptr
      ref_count(ptr).must_equal 1

      GC.start
      # Creating a new object is sometimes needed to trigger enough garbage collection.
      GObject::Object.new
      sleep 1

      GC.start
      GC.start

      ref_count(ptr).must_equal 0
    end
  end
end
