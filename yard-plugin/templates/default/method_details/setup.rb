# frozen_string_literal: true
def init
  super
  sections.last.place(:overrides).before(:source)
end
