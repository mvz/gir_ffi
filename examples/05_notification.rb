#
# Simple notification example.
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'ffi-gtk3'

GirFFI.setup :Notify

# Both Gtk and Notify need to be init'ed.
Gtk.init
Notify.init "notification test"

# Basic set up of the notification.
nf = Notify::Notification.new "Hello!", "Hi there.", "gtk-dialog-info"
nf.timeout = 3000
nf.urgency = :critical

# Show a button 'Test' in the notification, with a callback function.
nf.add_action "test", "Test", Proc.new { |obj, action, user_data|
  puts "Action #{action} clicked."
}, nil, nil

# In this case, we want the program to end once the notification is gone,
# but not before.
GObject.signal_connect(nf, "closed") {
  puts "Notification closed."
  Gtk.main_quit
}

# Show the notification.
nf.show

# Start a main loop to wait for the notification to be closed.
Gtk.main
