require "yast/rake"
require "pathname"

Yast::Tasks.configuration do |conf|
  #lets ignore license check for now
  conf.skip_license_check << /.*/
end

#
# freetype2 binding
#
extname = "ft2_rendering"
olddir = Dir.pwd
Dir.chdir("src/ext/#{extname}")
ruby 'extconf.rb'
sh 'make'
Dir.chdir(olddir)
# for testing {
unless FileTest.exist?("src/lib/yast")
  FileUtils.ln_s("../ext/#{extname}", "src/lib/yast")
end
# }

