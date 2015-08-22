def init
  super
  sections.last.place(:overrides).before(:source)
end
