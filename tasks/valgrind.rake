task :valgrind do
  `valgrind --suppressions=gir_ffi-ruby1.9.1.supp ruby1.9.1 -Ilib -e "require 'gir_ffi'"`
end
