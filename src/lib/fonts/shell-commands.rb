module FontsConfig
  include Yast
  BASH_SCR_PATH = Path.new(".target.bash_output")

  class FontconfigCommands

    BLACKLIST_FAMILIES = [
      "micro.pcf",
      "deccurs.pcf",
      "decsess.pcf",
      "cursor.pcf",
    ]

    def self.installed_families(pattern_elements)
      cmd = "fc-list : #{pattern_elements} | sed 's@,.*:@:@' | sort | uniq"
      result = Yast::SCR.Execute(BASH_SCR_PATH, cmd)
      if (result["exit"].zero?)
        families = result["stdout"].split("\n")
        for bf in BLACKLIST_FAMILIES do
          families.delete_if{|f| f =~ /#{bf}/}
        end
        return families
      else
        return []
      end
    end

    def self.is_family_installed(family)
      cmd="fc-list --quiet \"" + family + "\""
      Yast::SCR.Execute(BASH_SCR_PATH, cmd)["exit"].zero?
    end
  end

  class FontsConfigCommand
    
    def self.run_fonts_config
      cmd = "/usr/sbin/fonts-config"
      result = Yast::SCR.Execute(BASH_SCR_PATH, cmd)
      unless (result["exit"].zero?)     
        raise cmd + " run failed:" + result["stdout"]
      end
    end
  end
end
