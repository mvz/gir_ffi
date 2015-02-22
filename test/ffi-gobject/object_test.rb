require 'gir_ffi_test_helper'

require 'ffi-gobject'

describe GObject::Object do
  describe '#get_property' do
    it 'is overridden to have arity 1' do
      assert_equal 1,
                   GObject::Object.instance_method('get_property').arity
    end
  end

  describe 'automatic accessor methods' do
    class AccessorTest < GObject::Object
      def get_x
        @x
      end

      def set_x val
        @x = val
      end
    end

    subject { AccessorTest.new GObject::TYPE_OBJECT, nil }

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
    subject { GObject::Object.new GObject::TYPE_OBJECT, nil }

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
    subject { GObject::Object.new GObject::TYPE_OBJECT, nil }

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
end
