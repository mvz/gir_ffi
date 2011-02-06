module GirFFI
  class ArgumentBuilder
    attr_accessor :arginfo, :inarg, :callarg, :retval, :pre, :post,
      :postpost, :name, :retname
    def initialize arginfo=nil
      self.arginfo = arginfo
      self.inarg = nil
      self.callarg = nil
      self.retval = nil
      self.retname = nil
      self.name = nil
      self.pre = []
      self.post = []
      self.postpost = []
    end
  end
end
