require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'ffi-gobject/ruby_style'

describe GObject::RubyStyle do
  class RubyStyleTest
    include GObject::RubyStyle
    def get_x
      @x
    end
    def set_x(val)
      @x = val
    end
  end

  subject { RubyStyleTest.new }

  it 'reads x by calling get_x' do
    subject.set_x(1)
    assert_equal 1, subject.x
  end

  it 'writes x by calling set_x' do
    subject.x = 2
    assert_equal 2, subject.x
  end

  it 'delegates signal_connect to GObject' do
    block = lambda {}
    mock(GObject).signal_connect(subject, 'some-event')
    subject.signal_connect('some-event') do
      nothing
    end

    RR.verify
  end

end

