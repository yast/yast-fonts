require "yast/rake"

Yast::Tasks.submit_to :sle15sp1
require "pathname"

Yast::Tasks.configuration do |conf|
  #lets ignore license check for now
  conf.skip_license_check << /.*/
end

task :compile do
  olddir = Dir.pwd
  ["ft2_rendering", "fontconfig_setting", "font_specimen"].each do |ext|
    Dir.chdir("src/ext/#{ext}")
    ruby 'extconf.rb'
    sh 'make'
    Dir.chdir(olddir)
  end
end

namespace :test do
  task :prepare => :compile do
    # let yast know where ft2_rendering extension is
    mkdir_p "src/lib/yast"
    ["ft2_rendering", "fontconfig_setting", "font_specimen"].each do |ext|
      ln_sf("../../ext/#{ext}/#{ext}.so", "src/lib/yast/#{ext}.so")
    end
  end

  task :unit => :prepare do
    rm_r("src/lib/yast") if FileTest.exists?("src/lib/yast")
  end
end

task :run => "test:prepare" do
  rm_r("src/lib/yast") if FileTest.exists?("src/lib/yast")
end

task :clean do
  rm_f("src/ext/*/*.so")
  rm_f("src/ext/*/*.o")
  rm_f("src/ext/*/Makefile")
  rm_f("src/ext/*/yast")
  rm_rf("src/lib/yast")
end

