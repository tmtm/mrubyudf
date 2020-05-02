require "mrubyudf/version"

class MrubyUdf
  class << self
    attr_writer :function
    def function(&block)
      f = MrubyUdf::Function.new
      block.call f
      self.function = f
    end
  end
end
