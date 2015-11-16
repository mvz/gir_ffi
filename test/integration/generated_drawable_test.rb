require 'gir_ffi_test_helper'

GirFFI.setup :Drawable

class ConcreteDrawable < Drawable::Drawable
  def initialize
    super(self.class.gtype, [])
  end
end

GirFFI.define_type ConcreteDrawable

describe Drawable do
  describe 'Drawable::Drawable' do
    let(:instance) { ConcreteDrawable.new }
    it 'has a working method #do_foo' do
      instance.do_foo 42
      pass
    end

    it 'has a working method #do_foo_maybe_throw' do
      instance.do_foo_maybe_throw 42
      proc { instance.do_foo_maybe_throw 41 }.must_raise GirFFI::GLibError
    end

    it 'has a working method #get_origin' do
      instance.get_origin.must_equal [0, 0]
    end

    it 'has a working method #get_size' do
      instance.get_size.must_equal [42, 42]
    end
  end

  describe 'Drawable::PixmapObjectClass' do
    it 'has a writable field parent_class' do
      skip 'This is a class struct without defined class'
    end
  end
end
