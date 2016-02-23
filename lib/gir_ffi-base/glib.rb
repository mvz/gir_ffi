# frozen_string_literal: true

# Ensure GLib is defined by GirFFI itself
raise 'The module GLib was already defined elsewhere' if Kernel.const_defined? :GLib

# Module representing GLib's GLib namespace.
module GLib
end
