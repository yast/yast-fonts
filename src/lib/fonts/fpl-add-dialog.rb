module FontsConfig
  class FPLAddDialog
    include Yast
    include UIShortcuts
    include I18n

    BLACKLIST = [
      "micro.pcf",
      "deccurs.pcf",
      "decsess.pcf",
      "cursor.pcf",
    ]

    def initialize(fcstate)
      @fcstate = fcstate
      @available_families = FontconfigCommands::installed_families("family fontformat")
      # delete families, that are part of list for some alias
      if (@available_families)
        for key in @fcstate.fpl.keys do
          for family in  @fcstate.fpl[key] do
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
                fontformat = family.gsub(/.*fontformat=([^:]+).*/, '\1')
                family = family[/^[^:]*/]
                Item(Id(family), family, fontformat)
              end

      dialog_content = VBox(
                        MinSize(40, 16,
                                Table(Id("tbl_family_names"),
                                      Opt(:keepSorting, :notify, :immediate),
                                      Header(_("Installed Families"), 
                                             _("Font Format")),
                                      items)),
                        InputField(Id("txt_family_name"), 
                                   Opt(:notify, :immediate, :hstretch),
                                   _("&Filter"), ""),
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
    def controller_loop
      while true do
        input = UI.UserInput
        case input
          when "btn_add"
            family = UI.QueryWidget(Id("tbl_family_names"), :CurrentItem)
            return family != "" ? family : nil
          when "txt_family_name"
            substring = UI.QueryWidget(Id("txt_family_name"), :Value)
            filtered_families = @available_families.select{|f| f[/#{substring}/]}
            items = filtered_families.map do |family|
                    Item(Id(family), family)
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
