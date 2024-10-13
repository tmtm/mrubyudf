MRuby::Build.new do |conf|
  @exts.library = '.so'
  conf.gembox 'default'
  conf.toolchain
  conf.cc do |cc|
    cc.flags = '-fPIC'
  end
  conf.archiver do |archiver|
    archiver.command = 'gcc'
    archiver.archive_options = '-shared -o %{outfile} %{objs}'
  end
end
