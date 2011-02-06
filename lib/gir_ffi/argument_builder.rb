module GirFFI
  class ArgumentBuilder
    attr_accessor :arginfo, :inarg, :callarg, :retval, :pre, :post,
      :postpost, :name, :retname

    def initialize function_builder, arginfo=nil
      self.arginfo = arginfo
      self.inarg = nil
      self.callarg = nil
      self.retval = nil
      self.retname = nil
      self.name = nil
      self.pre = []
      self.post = []
      self.postpost = []
      @function_builder = function_builder
    end
  end
end
