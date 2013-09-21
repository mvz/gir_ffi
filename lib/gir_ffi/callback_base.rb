require 'gir_ffi/type_base'

module GirFFI
  class CallbackBase < Proc
    include TypeBase
  end
end
