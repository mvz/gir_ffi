module GirFFI
  # Provides methods needed by all generated classes
  module ClassBase
    def initialize ptr
      @gobj = ptr
    end
    def to_ptr
      @gobj
    end
  end
end
