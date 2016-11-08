require "yast/fontconfig_setting"
require "yast/font_specimen"

module FontsConfig
  class FPLAddDialog
    include Yast
    include UIShortcuts
    include I18n
    include FontconfigSetting
    include FontSpecimen

    BLACKLIST = [
      "micro.pcf",
      "deccurs.pcf",
      "decsess.pcf",
      "cursor.pcf",
    ]

    def initialize(fcstate)
      textdomain "fonts"

      @fcstate = fcstate
      @available_families = installed_families(["family", "fontformat"])
      if (@available_families)
        # bsc#998300
        # fontconfig can return families with the comma; remove
        # the redundant part and delete duplicate families: e. g.
        #           Source Sans Pro,Source Sans Pro Black
        #           Source Sans Pro,Source Sans Pro Semibold
        #               => Source Sans Pro
        @available_families.map!{|family| family.gsub(/,.*:/, ':')}.uniq!.sort!
        # delete families, that are part of list for some alias
        @fcstate.fpl.keys.each do |key|
          @fcstate.fpl[key].each do |family|
            if (@available_families.index(family))
              @available_families.delete_if{|f| f =~ /#{family}/}
            end
          end
        end
        # delete blacklisted families
        BLACKLIST.each do |black_family|
          @available_families.delete_if{|f| f =~ /#{black_family}/}
        end
        @available_families.each do |family|
          pattern = parse_pattern(family)
          scripts = font_scripts(pattern["family"]).
                      map{|script, coverage| "#{script}(#{coverage})"}.
                        join(',')
          family << ':scripts=' << scripts
        end
      end
    end

    def run
      Yast.import "UI"
      items = @available_families.map do |family|
                pattern = parse_pattern(family)
                Item(Id(pattern["family"]), pattern["family"], 
                        pattern["fontformat"], pattern["scripts"])
              end

      dialog_content = VBox(
                        InputField(Id("txt_family_name"), 
                                   Opt(:notify, :immediate, :hstretch),
                                   _("&Filter"), ""),
                        MinSize(70, 16,
                                Table(Id("tbl_family_names"),
                                      Opt(:notify, :immediate),
                                      Header(_("Installed Families"), 
                                             _("Font Format"),
                                             _("Script Coverages")),
                                      items)),
                        HBox(PushButton(Id("btn_cancel"), _("&Cancel")),
                             PushButton(Id("btn_add"), _("&Add"))),
                       )
      UI.OpenDialog dialog_content

      begin
        return controller_loop
      ensure
        UI.CloseDialog
      end
    end

  private
    def parse_pattern(str_pattern)
      pattern = Hash.new
      pattern["family"] = str_pattern[/^[^:]*/]
      pattern["fontformat"] = str_pattern.gsub(/.*fontformat=([^:]+).*/, '\1')
      pattern["scripts"] = str_pattern.gsub(/.*scripts=([^:]+).*/, '\1')
      pattern
    end

    def controller_loop
      while true do
        input = UI.UserInput
        case input
          when "btn_add"
            family = UI.QueryWidget(Id("tbl_family_names"), :CurrentItem)
            return family != "" ? family : nil
          when "txt_family_name"
            substring = UI.QueryWidget(Id("txt_family_name"), :Value)
            filtered_families = @available_families.select{|f| f[/#{substring}/i]}
            items = filtered_families.map do |family|
                    pattern = parse_pattern(family)
                    Item(Id(pattern["family"]), pattern["family"], 
                         pattern["fontformat"], pattern["scripts"])
                    end
            UI.ChangeWidget(Id("tbl_family_names"),
                            :Items, items)
          when "btn_cancel"
            return nil
        end
      end
    end
  end
end
