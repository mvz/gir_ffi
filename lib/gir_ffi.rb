require 'ffi'

require 'gir_ffi-base'

require 'ffi-gobject_introspection'

require 'gir_ffi/ffi_ext'
require 'gir_ffi/class_base'
require 'gir_ffi/type_map'
require 'gir_ffi/info_ext'
require 'gir_ffi/in_pointer'
require 'gir_ffi/in_out_pointer'
require 'gir_ffi/zero_terminated'
require 'gir_ffi/arg_helper'
require 'gir_ffi/builder'

module GirFFI
  def self.setup module_name, version=nil
    module_name = module_name.to_s
    GirFFI::Builder.build_module module_name, version
  end

  def self.define_type klass, &block
    info = UserDefinedTypeInfo.new(klass, &block)
    Builders::UserDefinedBuilder.new(info).build_class

    klass.get_gtype
  end
end

require 'ffi-glib'
require 'ffi-gobject'
