task :valgrind do
  `valgrind --suppressions=gir_ffi-ruby1.9.1.supp --leak-check=full ruby1.9.1 -Ilib -e "require 'ffi-gobject_introspection'"`
end
