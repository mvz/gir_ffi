Feature: Conflicting modules

  Scenario: Loading gir_ffi after a core module has been defined
    Given a file named "conflict.rb" with:
      """
      module GLib
      end

      require 'gir_ffi'

      puts 'do not print me'
      """
    And I run `ruby conflict.rb`
    Then the output should contain "already defined"
    And the output should not contain "do not print me"
    And the exit status should be 1
