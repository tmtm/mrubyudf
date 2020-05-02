require 'erb'

class MrubyUdf
  class Template
    attr_reader :func

    def initialize(func)
      @func = func
    end

    def result
      template = File.read("#{__dir__}/template.erb")
      ERB.new(template).result(func.context)
    end
  end
end
