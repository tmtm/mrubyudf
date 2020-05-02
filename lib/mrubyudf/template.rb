require 'erb'

class MrubyUdf
  class Template
    attr_reader :func

    def initialize(func)
      @func = func
    end

    def output
      ERB.new(DATA.read).result(func.context)
    end
  end
end

__END__
#include <stdio.h>
#include <string.h>
#include "mruby.h"
#include "mruby/string.h"
#include "mruby/irep.h"
#include "mysql.h"

extern const uint8_t <%= name %>_mrb[];

bool <%= name %>_init(UDF_INIT *initid, UDF_ARGS *args, char *message)
{
  if (args->arg_count != <%= nargs %>) {
    strcpy(message, "<%= name %>() requires <%= nargs %> argument(s)");
    return true;
  }
  <% arguments.each_with_index do |arg, i| %>
  args->arg_type[<%= i %>] = <%= arg.mysql_type %>;
  <% end %>
  mrb_state *mrb = mrb_open();
  if (!mrb) {
    strcpy(message, "mrb_open() error");
    return true;
  }
  initid->ptr = (void *)mrb;
  mrb_load_irep(mrb, <%= name %>_mrb);
  if (mrb->exc) {
    mrb_value s = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
    const char *cs = mrb_string_value_cstr(mrb, &s);
    strncpy(message, cs, MYSQL_ERRMSG_SIZE);
    fprintf(stderr, "%s\n", cs);
    return true;
  }
  return false;
}

void <%= name %>_deinit(UDF_INIT *initid)
{
  mrb_state *mrb = (mrb_state *)initid->ptr;
  if (mrb) {
    mrb_close(mrb);
  }
}

long long <%= name %>(UDF_INIT *initid, UDF_ARGS *args, char *is_null, char *error)
{
  mrb_state *mrb = (mrb_state *)initid->ptr;
  long long n = *((long long *)args->args[0]);
  mrb_value ret = mrb_funcall(mrb, mrb_top_self(mrb), "<%= name %>", <%= nargs %>, <%= arg_mysql_to_mruby %>);
  if (mrb->exc) {
    mrb_value s = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
    fprintf(stderr, "<%= name %>(%lld): %s\n", n, mrb_string_value_cstr(mrb, &s));
    *is_null = true;
    return 0;
  }
  return mrb_fixnum(ret);
}
