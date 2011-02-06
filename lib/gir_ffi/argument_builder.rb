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

    def process
      arg = self.arginfo
      case arg.direction
      when :inout
	@function_builder.process_inout_arg self
      when :in
	@function_builder.process_in_arg self
      when :out
	@function_builder.process_out_arg self
      else
	raise ArgumentError
      end
    end

  end
end
