module GirFFI
  module BuilderHelper
    def const_defined_for parent, name
      if RUBY_VERSION < "1.9"
        parent.const_defined? name
      else
        parent.const_defined? name, false
      end
    end

    def optionally_define_constant parent, name
      if const_defined_for parent, name
        parent.const_get name
      else
        parent.const_set name, yield
      end
    end

  end
end
