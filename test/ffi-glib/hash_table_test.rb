# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe GLib::HashTable do
  it 'knows its key and value types' do
    hsh = GLib::HashTable.new :gint32, :utf8
    assert_equal :gint32, hsh.key_type
    assert_equal :utf8, hsh.value_type
  end

  describe '::from' do
    it 'creates a GHashTable from a Ruby hash' do
      hsh = GLib::HashTable.from [:utf8, :gint32],
                                 'foo' => 23, 'bar' => 32
      assert_equal({ 'foo' => 23, 'bar' => 32 }, hsh.to_hash)
    end

    it 'return its argument if given a GHashTable' do
      hsh = GLib::HashTable.from [:utf8, :gint32], 'foo' => 23, 'bar' => 32
      hsh2 = GLib::HashTable.from [:utf8, :gint32], hsh
      assert hsh2.equal? hsh
    end

    it 'wraps its argument if given a pointer' do
      hsh = GLib::HashTable.from [:utf8, :gint32], 'foo' => 23, 'bar' => 32
      pointer = hsh.to_ptr
      assert_instance_of FFI::Pointer, pointer
      hsh2 = GLib::HashTable.from [:utf8, :gint32], pointer
      assert_instance_of GLib::HashTable, hsh2
      refute hsh2.equal? hsh
      hsh2.to_hash.must_equal hsh.to_hash
    end
  end

  it 'allows key-value pairs to be inserted' do
    h = GLib::HashTable.new :utf8, :utf8
    h.insert 'foo', 'bar'
    h.to_hash.must_equal 'foo' => 'bar'
  end

  it 'includes Enumerable' do
    GLib::HashTable.must_include Enumerable
  end

  describe 'a HashTable provided by the system' do
    before do
      GirFFI.setup :Regress
      @hash = Regress.test_ghash_container_return
    end

    it 'has a working #each method' do
      a = {}
      @hash.each { |k, v| a[k] = v }
      a.must_be :==,
                'foo' => 'bar',
                'baz' => 'bat',
                'qux' => 'quux'
    end

    it 'has a working #to_hash method' do
      @hash.to_hash.must_be :==,
                            'foo' => 'bar',
                            'baz' => 'bat',
                            'qux' => 'quux'
    end
  end
end
