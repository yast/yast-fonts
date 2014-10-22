require "yast/rake"
require "pathname"

Yast::Tasks.configuration do |conf|
  #lets ignore license check for now
  conf.skip_license_check << /.*/
end

extname = "ft2_rendering"

task :compile do
  #
  # freetype2 binding
  #
  olddir = Dir.pwd
  Dir.chdir("src/ext/#{extname}")
  ruby 'extconf.rb'
  sh 'make'
  Dir.chdir(olddir)
end

task :unittest => :compile do
  FileUtils.ln_s(".", "src/ext/#{extname}/yast") unless FileTest.exist?("yast")
  Rake::Task["test:unit"].invoke
end

task :test => :compile do
  FileUtils.ln_sf("../ext/#{extname}", "src/lib/yast")  unless FileTest.exists?("src/lib/yast")
  Rake::Task["run"].invoke
end

task :clean do
  FileUtils.rm_f("src/ext/#{extname}/ft2_rendering.so")
  FileUtils.rm_f("src/ext/#{extname}/ft2-rendering.o")
  FileUtils.rm_f("src/ext/#{extname}/Makefile")
  FileUtils.rm_f("src/ext/#{extname}/yast")
  FileUtils.rm_f("src/lib/yast")
end

