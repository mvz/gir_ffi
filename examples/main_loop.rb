require 'gir_ffi'

main_loop = GLib::MainLoop.new nil, false

Signal.trap("INT") do
  if main_loop.is_running
    main_loop.quit
  end
  exit
end

main_loop.run
