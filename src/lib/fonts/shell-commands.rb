require "yast"

module FontsConfig
  BASH_SCR_PATH = Yast::Path.new(".target.bash_output")

  class FontsConfigCommand
    
    def self.run_fonts_config
      cmd = "/usr/sbin/fonts-config"
      result = Yast::SCR.Execute(BASH_SCR_PATH, cmd)
      unless (result["exit"].zero?)   
        Yast.import "Popup"
        Yast::Popup.Error(cmd + " run failed:" + result["stdout"])
        return false
      end
      return true
    end
  end
end

