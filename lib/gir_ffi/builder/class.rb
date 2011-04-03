require 'gir_ffi/builder_helper'
require 'gir_ffi/builder/type/base'
module GirFFI
  # Builds a class based on information found in the introspection
  # repository.
  module Builder::Type
    def self.build info
      Base.new(info).generate
    end
  end
end
