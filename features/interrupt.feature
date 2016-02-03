Feature: Interrupting a program

  Scenario: Interrupting a program
    Given a file named "interrupt_me.rb" with:
      """
      require 'gir_ffi'

      loop = GLib::MainLoop.new nil, false
      Signal.trap 'INT' do
        GLib::MainLoop::EXCEPTIONS << Interrupt.new
        loop.quit
      end
      puts 'doing'
      loop.run
      puts 'done'
      """
    When I wait 2 seconds for a command to start up 
    And I run `ruby interrupt_me.rb` in background
    And I send the signal "INT" to the command started last
    Then the output should contain "doing"
    And the exit status should be 2
    And the output should not contain "done"
