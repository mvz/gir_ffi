# frozen_string_literal: true

require "introspection_test_helper"

require "gir_ffi"

# Global sequence provider. Needed to make unique class names.
class Sequence
  def self.next
    @seq ||= 0
    @seq += + 1
  end
end

module GirFFITestExtensions
  def object_ref_count(ptr)
    GObject::Object::Struct.new(ptr.to_ptr)[:ref_count]
  end

  def max_for_unsigned_type(type)
    (1 << (FFI.type_size(type) * 8)) - 1
  end

  def max_for_type(type)
    (1 << (FFI.type_size(type) * 8 - 1)) - 1
  end

  def min_for_type(type)
    ~max_for_type(type)
  end

  def max_long
    max_for_type :long
  end

  def min_long
    min_for_type :long
  end

  def max_size_t
    max_for_unsigned_type :size_t
  end

  def max_ssize_t
    # FFI has no :ssize_t, but it's the same number of bits as :size_t
    max_for_type :size_t
  end

  def min_ssize_t
    min_for_type :size_t
  end

  def max_ushort
    max_for_unsigned_type :ushort
  end

  def max_uint
    max_for_unsigned_type :uint
  end

  def max_ulong
    max_for_unsigned_type :ulong
  end
end

Minitest::Test.include GirFFITestExtensions
