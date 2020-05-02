class MrubyUdf
  class Function
    attr_accessor :name
    attr_accessor :return_type
    attr_accessor :arguments

    def initialize
      @name = nil
      @return_type = Integer
      @arguments = []
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
          "mrb_str_new_cstr(mrb, (char *)args->args[#{i}])"
        end
      end.join(", ")
    end

    def return_ctype
      case
      when return_type == Integer
        "long long"
      when return_type == Float
        "double"
      when return_type == String
        "char *"
      else
        raise "invalid return type: #{return_type}"
      end
    end


    def return_mruby_to_mysql
      case
      when return_type == Integer
        "mrb_fixnum(ret)"
      when return_type == Float
        "mrb_float(ret)"
      when return_type == String
        "RSTRING_PTR(ret)"
      else
        raise "invalid return type: #{return_type}"
      end
    end

    def context
      binding
    end
  end
end
