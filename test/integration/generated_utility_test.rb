# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe Utility do
  describe 'Utility::Buffer' do
    let(:instance) { Utility::Buffer.new }

    it 'has a writable field data' do
      instance.data.must_equal FFI::Pointer::NULL
      instance.data = FFI::Pointer.new 54_321
      instance.data.must_equal FFI::Pointer.new 54_321
    end

    it 'has a writable field length' do
      instance.length.must_equal 0
      instance.length = 42
      instance.length.must_equal 42
    end
  end

  describe 'Utility::Byte' do
    let(:instance) { Utility::Byte.new }

    it 'has a writable field value' do
      instance.value.must_equal 0
      instance.value = 42
      instance.value.must_equal 42
    end

    describe 'Utility::parts' do
      it 'has a writable field first_nibble' do
        skip 'Needs testing'
      end
      it 'has a writable field second_nibble' do
        skip 'Needs testing'
      end
    end
  end

  describe 'Utility::EnumType' do
    it 'has the member :a' do
      Utility::EnumType[:a].must_equal 0
    end

    it 'has the member :b' do
      Utility::EnumType[:b].must_equal 1
    end

    it 'has the member :c' do
      Utility::EnumType[:c].must_equal 2
    end
  end

  describe 'Utility::FlagType' do
    it 'has the member :a' do
      Utility::FlagType[:a].must_equal 1
    end

    it 'has the member :b' do
      Utility::FlagType[:b].must_equal 2
    end

    it 'has the member :c' do
      Utility::FlagType[:c].must_equal 4
    end
  end

  describe 'Utility::Object' do
    let(:instance) { Utility::Object.new }

    it 'has a working method #watch_dir' do
      # This method doesn't actually do anything
      instance.watch_dir('/') { }
      pass
    end
  end

  describe 'Utility::Struct' do
    let(:instance) { Utility::Struct.new }

    it 'has a writable field field' do
      instance.field.must_equal 0
      instance.field = 42
      instance.field.must_equal 42
    end

    it 'has a writable field bitfield1' do
      skip 'Needs testing'
    end
    it 'has a writable field bitfield2' do
      skip 'Needs testing'
    end
    it 'has a writable field data' do
      skip 'Needs testing'
    end
  end

  describe 'Utility::TaggedValue' do
    let(:instance) { Utility::TaggedValue.new }

    it 'has a writable field tag' do
      instance.tag.must_equal 0
      instance.tag = 42
      instance.tag.must_equal 42
    end

    describe 'Utility::value' do
      it 'has a writable field v_pointer' do
        skip 'Needs testing'
      end
      it 'has a writable field v_real' do
        skip 'Needs testing'
      end
      it 'has a writable field v_integer' do
        skip 'Needs testing'
      end
    end
  end

  describe 'Utility::Union' do
    let(:instance) { Utility::Union.new }

    it 'has a writable field pointer' do
      instance.pointer.must_be_nil
      instance.pointer = 'hello 42'
      instance.pointer.must_equal 'hello 42'
    end

    it 'has a writable field integer' do
      instance.integer.must_equal 0
      instance.integer = 42
      instance.integer.must_equal 42
    end

    it 'has a writable field real' do
      instance.real.must_equal 0.0
      instance.real = 42.23
      instance.real.must_equal 42.23
    end
  end

  it 'has a working function #dir_foreach' do
    skip 'Needs testing'
  end
end

