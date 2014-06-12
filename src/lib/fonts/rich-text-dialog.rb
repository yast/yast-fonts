module FontsConfig
  class RichTextDialog
    include Yast
    include UIShortcuts
    include I18n

    def initialize
    end

    def run(text, summary)
      Yast.import "UI"
      Yast.import "RichText"

      dialog_content = VBox(
                        Label(Id("lbl_message"), text),
                        MinSize(35, 16,
                                RichText(Id("rt_summary"), 
                                         Opt(:hstretch, :vstretch), 
                                         summary)
                               ),
                        PushButton(Id("btn_ok"), _("&Ok")),
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
          when "btn_ok"
            return true
        end
      end
    end
  end
end
