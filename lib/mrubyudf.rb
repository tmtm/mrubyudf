require_relative 'mrubyudf/version'
require_relative 'mrubyudf/function'
require_relative 'mrubyudf/template'

class MrubyUdf
  class << self
    def function(&block)
      return @function unless block
      f = MrubyUdf::Function.new
      block.call f
      @function = f
    end
  end
end
