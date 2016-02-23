Feature: Conflicting modules

  Scenario: Loading gir_ffi after a core module has been defined
    Given a file named "conflict.rb" with:
      """
      module GLib
        def self.hello
          puts 'This is a conflicting implementation of GLib'
        end
      end

      require 'gir_ffi'

      GLib.hello
      """
    And I run `ruby conflict.rb`
    Then the output should contain "already defined"
    And the exit status should be 1
