require 'gir_ffi/i_repository'
require 'gir_ffi/builder'

module GirFFI
  def self.setup module_name, version=nil
    module_name = module_name.to_s
    GirFFI::Builder.build_module module_name, version
  end
end
