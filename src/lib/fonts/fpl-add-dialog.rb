require "yast/fontconfig_setting"

module FontsConfig
  class FPLAddDialog
    include Yast
    include UIShortcuts
    include I18n
    include FontconfigSetting

    BLACKLIST = [
      "micro.pcf",
      "deccurs.pcf",
      "decsess.pcf",
      "cursor.pcf",
    ]

    def initialize(fcstate)
      @fcstate = fcstate
      @available_families = installed_families(["family", "fontformat"])
      # delete families, that are part of list for some alias
      if (@available_families)
         @fcstate.fpl.keys.each do |key|
          @fcstate.fpl[key].each do |family|
            if (@available_families.index(family))
              @available_families.delete_if{|f| f =~ /#{family}/}
            end
          end
        end
      end
    end

    def run
      Yast.import "UI"
      items = @available_families.map do |family|
                pattern = parse_pattern(family)
                Item(Id(pattern["family"]), pattern["family"], pattern["fontformat"])
              end

      dialog_content = VBox(
                        InputField(Id("txt_family_name"), 
                                   Opt(:notify, :immediate, :hstretch),
                                   _("&Filter"), ""),
                        MinSize(40, 16,
                                Table(Id("tbl_family_names"),
                                      Opt(:notify, :immediate),
                                      Header(_("Installed Families"), 
                                             _("Font Format")),
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
                    Item(Id(pattern["family"]), pattern["family"], pattern["fontformat"])
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
