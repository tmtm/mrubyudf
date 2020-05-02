class MrubyUdf
  class Function
    attr_reader :name
    attr_reader :return
    attr_reader :arguments

    def initialize
      @name = nil
      @return = Integer
      @arguments = []
    end

    def nargs
      @arguments.size
    end

    def context
      binding
    end
  end
end
