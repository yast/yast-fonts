require "yast/scr"
require "yast/path"

module FontsConfig
  BASH_SCR_PATH = Yast::Path.new(".target.bash_output")
  FONTS_CONFIG_CMD = "/usr/sbin/fonts-config"
  XDG_PREFIX = ENV['HOME'] + '/.config/'

  class FontsConfigCommand
    
    def self.run_fonts_config(args)
      return false unless File.executable?(FONTS_CONFIG_CMD)

      cmd = FONTS_CONFIG_CMD + " " + args
      result = Yast::SCR.Execute(BASH_SCR_PATH, cmd)
      unless (result["exit"].zero?)   
        Yast.import "Popup"
        Yast::Popup.Error(cmd + " run failed:" + result["stdout"])
        return false
      end
      return true
    end

    def self.local_family_list_file
      return fonts_config_file("local family list")
    end
  
    def self.rendering_config
      return fonts_config_file("rendering config")
    end

    def self.metric_compatibility_avail
      return fonts_config_file("metric compatibility avail")
    end

    def self.metric_compatibility_symlink
      return fonts_config_file("metric compatibility symlink")
    end

    def self.metric_compatibility_bw_symlink
      return fonts_config_file("metric compatibility bw symlink")
    end

    def self.sysconfig_file
      return fonts_config_file("sysconfig file")
    end

    def self.user_sysconfig_file
      return XDG_PREFIX + fonts_config_file("user sysconfig file")
    end

    def self.have_fonts_config?
      return File.executable?(FONTS_CONFIG_CMD)
    end

  private
    def self.fonts_config_file(file_id)
      return nil unless File.executable?(FONTS_CONFIG_CMD)

      cmd = "#{FONTS_CONFIG_CMD} --info"
      result = Yast::SCR.Execute(BASH_SCR_PATH, cmd)
      file = result["stdout"].lines.select{|l| l =~ /#{file_id}:/}[0].gsub(/.*: /, '').gsub(/\n/, '')
      if (!result["exit"].zero? || file.length == 0)
        Yast.import "Popup"
        Yast::Popup.Error(cmd + " run failed:" + result["stdout"])
        return nil
      end
      return file
    end
  end
end

