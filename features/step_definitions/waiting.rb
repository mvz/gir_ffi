# frozen_string_literal: true

When(/^I wait some time for a command to start up$/) do
  time = case RUBY_ENGINE
         when 'jruby'
           10
         when 'rbx'
           4
         else
           1
         end
  step "I wait #{time} seconds for a command to start up"
end
