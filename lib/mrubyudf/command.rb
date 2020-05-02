class MrubyUdf
  class Command
    def self.run
      self.new.run
    end

    def run
      parse_args(ARGV)
      load @spec
      Dir.chdir(File.dirname(@spec)) do
        compile
      end
    end

    def parse_args(args)
      raise "Usage: #$0 foo.spec" if args.size != 1
      @spec = args.first
    end

    def compile
      f = MrubyUdf.function
      c = MrubyUdf::Template.new(f).result
      File.write("#{f.name}_udf.c", c)
      mruby_path = ENV['MRUBY_PATH'] || search_mruby_path
      mrbc = [mruby_path, 'bin/mrbc'].join('/')
      cc = ENV['CC'] || 'gcc'
      cflags = ENV['CFLAGS'] || '-shared -fPIC'
      include_path = "-I #{mruby_path}/include #{mysql_include}"
      library_path = "-L #{mruby_path}/build/host/lib"
      exec_command "#{mrbc} -B #{f.name}_mrb #{f.name}.rb"
      exec_command "#{cc} #{cflags} #{include_path} #{f.name}_udf.c #{f.name}.c #{library_path} -lmruby -lm -o #{f.name}.so"
    end

    def exec_command(str)
      puts str
      stdout = %x(#{str})
      raise 'failed' unless $?.success?
      stdout.chomp
    end

    def search_mruby_path
      ENV['PATH'].split(/:/).each do |path|
        return File.dirname(path) if File.executable? "#{path}/mrbc"
      end
      raise "command not found: mrbc"
    end

    def mysql_include
      exec_command 'mysql_config --include'
    end
  end
end
