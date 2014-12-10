require "yast/scr"
require "yast/path"

module FontsConfig
  BASH_SCR_PATH = Yast::Path.new(".target.bash_output")
  FONTS_CONFIG_CMD = "/usr/sbin/fonts-config"

  class FontsConfigCommand
    
    def self.run_fonts_config
      return false unless File.executable?(FONTS_CONFIG_CMD)

      cmd = FONTS_CONFIG_CMD
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

    def self.metric_compatibility_config
      return fonts_config_file("metric compatibility config")
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

    def self.have_fonts_config?
      return File.executable?(FONTS_CONFIG_CMD)
    end

  private
    def self.fonts_config_file(file_id)
      return nil unless File.executable?(FONTS_CONFIG_CMD)

      cmd = "#{FONTS_CONFIG_CMD} --info | grep '#{file_id}:' | sed 's/.*: //' | tr -d '\n'"
      result = Yast::SCR.Execute(BASH_SCR_PATH, cmd)
      if (!result["exit"].zero? || result["stdout"].length == 0)
        Yast.import "Popup"
        Yast::Popup.Error(cmd + " run failed:" + result["stdout"])
        return nil
      end
      return result["stdout"]
    end
  end
end

