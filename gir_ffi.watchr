# Time notification will be displayed before disappearing automatically
EXPIRATION_IN_SECONDS = 2
ERROR_STOCK_ICON = "gtk-dialog-error"
SUCCESS_STOCK_ICON = "gtk-dialog-info"

# Convenience method to send an error notification message
#
# [stock_icon]   Stock icon name of icon to display
# [title]        Notification message title
# [message]      Core message for the notification
def notify stock_icon, title, message
  options = "-t #{EXPIRATION_IN_SECONDS * 1000} -i #{stock_icon}"
  system "notify-send #{options} '#{title}' '#{message}'"
end

def test_and_notify
  if system "rake test"
    notify SUCCESS_STOCK_ICON, "Green", "All tests passed, good job!"
  else
    notify ERROR_STOCK_ICON, "Red", "Some tests failed"
  end
end

watch( 'lib/.*\.rb' ) { |md| test_and_notify } 
watch( 'test/.*\.rb' ) { |md| test_and_notify }
