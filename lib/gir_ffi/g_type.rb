# Wrapper class providing extended functionality for a GType, which is normally
# just a kind of integer
class GirFFI::GType
  def initialize gtype
    @gtype = gtype
  end

  def to_i
    @gtype
  end

  def class_size
    type_query.class_size
  end

  def instance_size
    type_query.instance_size
  end

  private

  def type_query
    @type_query ||= GObject.type_query @gtype
  end
end
