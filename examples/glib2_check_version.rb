require "gir_ffi"

GirFFI.setup :GLib

def is_compatible?(major, minor, micro)
  check = GLib.check_version(major, minor, micro)
  compat_message = "Your GLib library is compatible with the given version"
  message = check || compat_message

  puts "version #{major}.#{minor}#{micro}"
  puts "\t#{message}\n"
end

# With a version of 2.46.2

is_compatible?(1, 46, 2)
is_compatible?(2, 43, 2)
is_compatible?(2, 46, 1)
is_compatible?(3, 46, 2)
