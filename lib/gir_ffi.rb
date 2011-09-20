require 'ffi'

require 'gir_ffi/class_base'
require 'gir_ffi/type_map'

require 'ffi-gobject_introspection'

require 'gir_ffi/arg_helper'
require 'gir_ffi/builder'

module GirFFI
  def self.setup module_name, version=nil
    module_name = module_name.to_s
    GirFFI::Builder.build_module module_name, version
  end
end

require 'ffi-glib'
require 'ffi-gobject'
