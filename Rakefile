require "yast/rake"
require "pathname"

Yast::Tasks.configuration do |conf|
  #lets ignore license check for now
  conf.skip_license_check << /.*/
end

task :compile do
  #
  # freetype2 binding
  #
  olddir = Dir.pwd
  Dir.chdir("src/ext/ft2_rendering")
  ruby 'extconf.rb'
  sh 'make'
  Dir.chdir(olddir)
end

namespace :test do
  task :prepare => :compile do
    # let yast know where ft2_rendering extension is
    ln_s("../ext/ft2_rendering", "src/lib/yast")  unless FileTest.exists?("src/lib/yast")
  end

  task :unit => :prepare do
    rm("src/lib/yast") if FileTest.exists?("src/lib/yast")
  end
end

task :run => "test:prepare" do
  rm("src/lib/yast") if FileTest.exists?("src/lib/yast")
end

task :clean do
  FileUtils.rm("src/ext/ft2_rendering/ft2_rendering.so")
  FileUtils.rm("src/ext/ft2_rendering/ft2-rendering.o")
  FileUtils.rm("src/ext/ft2_rendering/Makefile")
  FileUtils.rm("src/ext/ft2_rendering/yast")
  FileUtils.rm("src/lib/yast")
end

