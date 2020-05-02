class MrubyUdf
  class Function
    attr_accessor :name
    attr_accessor :return
    attr_accessor :arguments

    def initialize
      @name = nil
      @return = Integer
      @arguments = []
    end

    def nargs
      @arguments.size
    end

    def mysql_type(arg)
      case
      when arg == Integer
        "INT_RESULT"
      when arg == Float
        "REAL_RESULT"
      when arg == String
        "STRING_RESULT"
      else
        raise "invalid type: #{arg}"
      end
    end

    def arg_mysql_to_mruby
      arguments.map.with_index do |arg, i|
        case
        when arg == Integer
          "mrb_fixnum_value(*((long long *)args->args[#{i}]))"
        when arg == Float
          "mrb_float_value(*((double *)args->args[#{i}]))"
        when arg == String
          "mrb_str_to_cstr((char *)args->args[#{i}])"
        end
      end.join(", ")
    end

    def context
      binding
    end
  end
end
