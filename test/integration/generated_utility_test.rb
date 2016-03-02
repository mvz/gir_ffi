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

    it 'has a writable field first_nibble' do
      skip 'This field is not exposed in the GIR'
      instance.value = 0xAB
      instance.first_nibble.must_equal 0xA
      instance.first_nibble = 0x4
      instance.value.must_equal 0x4B
    end

    it 'has a writable field second_nibble' do
      skip 'This field is not exposed in the GIR'
      instance.value = 0xAB
      instance.second_nibble.must_equal 0xB
      instance.second_nibble = 0x4
      instance.value.must_equal 0xA4
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
      instance.watch_dir('/') {}
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
      skip 'Bitfield bit width is not implemented yet'
      instance.bitfield1.must_equal 0
      instance.bitfield1 = 15
      instance.bitfield1.must_equal 7
    end

    it 'has a writable field bitfield2' do
      skip 'Bitfield bit width is not implemented yet'
      instance.bitfield2.must_equal 0
      instance.bitfield2 = 15
      instance.bitfield2.must_equal 3
    end

    it 'has a writable field data' do
      instance.data.to_a.must_equal [0] * 16
    end
  end

  describe 'Utility::TaggedValue' do
    let(:instance) { Utility::TaggedValue.new }

    it 'has a writable field tag' do
      instance.tag.must_equal 0
      instance.tag = 42
      instance.tag.must_equal 42
    end

    it 'has a writable field v_pointer' do
      skip 'This field is not exposed in the GIR'
      instance.v_pointer.must_equal FFI::Pointer::NULL
      instance.v_pointer = FFI::Pointer.new(4321)
      instance.v_pointer.must_equal FFI::Pointer.new(4321)
    end

    it 'has a writable field v_real' do
      skip 'This field is not exposed in the GIR'
      instance.v_real.must_equal 0.0
      instance.v_real = 42.23
      instance.v_real.must_equal 42.23
    end

    it 'has a writable field v_integer' do
      skip 'This field is not exposed in the GIR'
      instance.v_integer.must_equal 0
      instance.v_integer = 42
      instance.v_integer.must_equal 42
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
    # This method doesn't actually do anything
    result = Utility.dir_foreach('/') {}
    result.must_be_nil
  end
end
