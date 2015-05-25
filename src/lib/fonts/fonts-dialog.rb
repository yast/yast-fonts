require "fileutils"
require "tmpdir"

require "yast"

require "fonts/fonts-config-state"
require "fonts/fpl-add-dialog"
require "fonts/select-ebl-dialog"
require "fonts/shell-commands"
require "fonts/rich-text-dialog"

require "yast/ft2_rendering"
require "yast/fontconfig_setting"
require "yast/font_specimen"

module FontsConfig
  class FontsConfigDialog
    include Yast
    include UIShortcuts
    include I18n
    include Ft2Rendering
    include FontconfigSetting
    include FontSpecimen
    include FileUtils

    SPECIMEN_SIZE = 250
    # This path is constant enough to have it hardcoded
    # here. fonts-config/FontsConfigCommand
    # could provide it, yes.
    FONTCONFIG_PATH = "/etc/fonts"

    def initialize
      textdomain "fonts"

      @fcstate = FontsConfigState.new(root_user?)
      @current_fpl = @fcstate.fpl.keys[0]
      @current_family = nil
      @current_families = Hash.new
      @current_scripts = Hash.new
      @fcstate.fpl.keys.each do |generic_alias|
        @current_families[generic_alias] = nil
        @current_scripts[generic_alias] = nil
      end
      @tmp_dir = Dir.mktmpdir("yast-fonts-")
      @fontconfig_path = FONTCONFIG_PATH
    end

    def self.run
      fontsconfig_dialog = FontsConfigDialog.new
      fontsconfig_dialog.run
      # for testsuite
      return @fcstate
    end

    def run
      run_dialog
    end

  private
    def initialize_antialias_checkbox(key = nil)
      UI.ChangeWidget(Id("chkb_antialias"), :Value,
                      !@fcstate.force_aa_off)
    end

    def handle_antialias_checkbox(key, map)
      @fcstate.force_aa_off =
        !UI.QueryWidget(Id("chkb_antialias"), :Value)
      UI.ChangeWidget(Id("chkb_antialias_mono"), :Enabled, !@fcstate.force_aa_off)
      return nil
    end

    def initialize_antialias_mono_checkbox(key = nil)
      UI.ChangeWidget(Id("chkb_antialias_mono"), :Value,
                      !@fcstate.force_aa_off_mono)
      UI.ChangeWidget(Id("chkb_antialias_mono"), :Enabled, !@fcstate.force_aa_off)
    end

    def handle_antialias_mono_checkbox(key, map)
      @fcstate.force_aa_off_mono =
        !UI.QueryWidget(Id("chkb_antialias_mono"), :Value)
      return nil
    end

    def initialize_ahon_checkbox(key = nil)
      UI.ChangeWidget(Id("chkb_ah_on"), :Value,
                      @fcstate.force_ah_on)
    end

    def handle_ahon_checkbox(key, map)
      @fcstate.force_ah_on =
        UI.QueryWidget(Id("chkb_ah_on"), :Value)
      return nil
    end

    def initialize_searchmc_checkbox(key = nil)
      UI.ChangeWidget(Id("chkb_search_mc"), :Value,
                      @fcstate.search_metric_compatible)
    end

    def handle_searchmc_checkbox(key, map)
      @fcstate.search_metric_compatible  =
        UI.QueryWidget(Id("chkb_search_mc"), :Value)
      return nil
    end

    def initialize_noother_checkbox(key = nil)
      UI.ChangeWidget(Id("chkb_no_other"), :Value,
                      @fcstate.really_force_fpl)
    end

    def handle_noother_checkbox(key, map)
      @fcstate.really_force_fpl =
        UI.QueryWidget(Id("chkb_no_other"), :Value)
      return nil
    end

    def initialize_hintstyle_combo(key = nil)
      UI.ChangeWidget(Id("cmb_hintstyle"), :Items, 
                      FontsConfigState::HINT_STYLES)
      UI.ChangeWidget(Id("cmb_hintstyle"), :Value, 
                      @fcstate.force_hintstyle)
    end

    def handle_hintstyle_combo(key, map)
      @fcstate.force_hintstyle =
        UI.QueryWidget(Id("cmb_hintstyle"), :Value)
      return nil
    end

    def initialize_lcdfilter_combo(key = nil)
      UI.ChangeWidget(Id("cmb_lcd_filter"), :Items, 
                      FontsConfigState::LCD_FILTERS)
      UI.ChangeWidget(Id("cmb_lcd_filter"), :Value, 
                      @fcstate.lcd_filter)
    end

    def handle_lcdfilter_combo(key, map)
      @fcstate.lcd_filter =
        UI.QueryWidget(Id("cmb_lcd_filter"), :Value)
      subpixel_freetype_warning
      return nil
    end

    def initialize_subpixellayout_combo(key = nil)
      UI.ChangeWidget(Id("cmb_subpixel_layout"), :Items, 
                      FontsConfigState::SUBPIXEL_LAYOUTS)
      UI.ChangeWidget(Id("cmb_subpixel_layout"), :Value, 
                      @fcstate.subpixel_layout)
      UI.ChangeWidget(Id("cmb_lcd_filter"), :Enabled,
           @fcstate.subpixel_layout != FontsConfigState::SUBPIXEL_LAYOUTS[0])
    end

    def handle_subpixellayout_combo(key, map)
      @fcstate.subpixel_layout =
        UI.QueryWidget(Id("cmb_subpixel_layout"), :Value)
      UI.ChangeWidget(Id("cmb_lcd_filter"), :Enabled,
           @fcstate.subpixel_layout != FontsConfigState::SUBPIXEL_LAYOUTS[0])
      return nil
    end

    def initialize_genericaliases_table(key = nil)
      items = []
      @fcstate.fpl.keys.each do |generic_alias|
        items.push(Item(generic_alias)) 
      end
      UI.ChangeWidget(Id("tbl_generic_aliases"), 
                      :Items, items)
    end

    def handle_genericaliases_table(key, map)
       @current_fpl=UI.QueryWidget(Id("tbl_generic_aliases"), 
                                   :CurrentItem)
       initialize_familylist_widget(key)
       return nil
    end

    def initialize_familylist_widget(key = nil)
      items = []
      @fcstate.fpl[@current_fpl].each do |f|
        indication = family_installed?(f) ?
                       _("installed") : _("not installed")
        items.push(Item(f, indication))
      end
      UI.ChangeWidget(Id("tbl_family_list"), :Items, 
                      items)
      if @current_family != nil
        UI.ChangeWidget(Id("tbl_family_list"), :CurrentItem, @current_family)
      end
      UI.ReplaceWidget(Id(:rp_label_family_list),
                       Label(_("Preference List for %s") % @current_fpl))
      UI.ChangeWidget(Id("btn_add_manual"), :Enabled, 
                      UI.QueryWidget(Id("txt_add_manual"), :Value) != "")
    end

    def handle_familylist_widget(key, map)
      @current_family = UI.QueryWidget(Id("tbl_family_list"), 
                                       :CurrentItem)
      index = @fcstate.fpl[@current_fpl].index(@current_family)
      size = @fcstate.fpl[@current_fpl].size

      case map["ID"]
        when "btn_up"
          if size == 0
            return nil
          end
          if index == 0 
            return nil
          end
          @fcstate.fpl[@current_fpl].delete_at(index) 
          @fcstate.fpl[@current_fpl].insert(index - 1, @current_family)
        when "btn_down"
          if size == 0
            return nil
          end
          if index == size - 1
            return nil
          end
          @fcstate.fpl[@current_fpl].delete_at(index) 
          @fcstate.fpl[@current_fpl].insert(index + 1, @current_family)
        when "btn_add_dialog"
          if size == 0
            index = 0
          end
          fpl_add_dialog = FPLAddDialog.new(@fcstate)
          family = fpl_add_dialog.run
          if family != nil
            @fcstate.fpl[@current_fpl].insert(index, family)
          end
        when "btn_remove"
          if size == 0
            return nil
          end
          @fcstate.fpl[@current_fpl].delete_at(index)
        when "txt_add_manual"
          # nothing to do here, initialize_familylist_widget will
          # toggle off/on btn_add_manual as appropriate
        when "btn_add_manual"
          if size == 0
            index = 0
          end
          family = UI.QueryWidget(Id("txt_add_manual"), :Value)
          @fcstate.fpl[@current_fpl].insert(index, family)
          UI.ChangeWidget(Id("txt_add_manual"), :Value, "")
      end

      initialize_familylist_widget
      return nil
    end

    def initialize_embeddedbitmaps_widget(key = nil)
      UI.ChangeWidget(Id("lbl_ebl"), :Value, 
                      Languages::names(@fcstate.ebl).join(", "))

      if @fcstate.all_ebl
        UI.ChangeWidget(Id("rbg_ebl"), :CurrentButton, "rbtn_ebl_all")
      else
        UI.ChangeWidget(Id("rbg_ebl"), :CurrentButton, "rbtn_ebl_selected")
      end

      if @fcstate.embedded_bitmaps
        UI.ChangeWidget(Id("chkb_ebitmaps_on"), :Value, true)
        UI.ChangeWidget(Id("rbg_ebl"), :Enabled, true)
        if @fcstate.all_ebl
          UI.ChangeWidget(Id("lbl_ebl"), :Enabled, false)
          UI.ChangeWidget(Id("btn_select_ebl"), :Enabled, false)
        else
          UI.ChangeWidget(Id("lbl_ebl"), :Enabled, true)
          UI.ChangeWidget(Id("btn_select_ebl"), :Enabled, true)
        end
      else
          UI.ChangeWidget(Id("chkb_ebitmaps_on"), :Value, false)
          UI.ChangeWidget(Id("rbg_ebl"), :Enabled, false)
          UI.ChangeWidget(Id("btn_select_ebl"), :Enabled, false)
          UI.ChangeWidget(Id("lbl_ebl"), :Enabled, false)
      end
    end

    def handle_embeddedbitmaps_widget(key, map)
      case map["ID"]
        when "btn_select_ebl"
          select_ebl_dialog = SelectEBLDialog.new
          items = select_ebl_dialog.run(@fcstate.ebl) 
          @fcstate.ebl = items
        when "chkb_ebitmaps_on"
          @fcstate.embedded_bitmaps = !@fcstate.embedded_bitmaps 
        when "rbtn_ebl_all"
          @fcstate.all_ebl = true
        when "rbtn_ebl_selected"
          @fcstate.all_ebl = false
      end
 
      initialize_embeddedbitmaps_widget
      return nil
    end

    def handle_presets_button(widget, event)
      if event && event["EventType"] == "MenuEvent" && 
           FontsConfigState::preset?(event["ID"])
        @fcstate.load_preset(event["ID"])
        if CWMTab.CurrentTab == "specimens"
          initialize_specimen_widget
        elsif CWMTab.CurrentTab == "algorithms"
          initialize_antialias_checkbox
          initialize_antialias_mono_checkbox
          initialize_ahon_checkbox
          initialize_hintstyle_combo
          initialize_lcdfilter_combo
          initialize_subpixellayout_combo
          initialize_embeddedbitmaps_widget
        else
          initialize_genericaliases_table
          initialize_familylist_widget
          initialize_searchmc_checkbox
          initialize_noother_checkbox
        end
        subpixel_freetype_warning
        installation_summary_check
      end
      return nil
    end

    def graphic_match_preview(family, script, generic_alias, specimen_ok)
        if (script)
          text = _("<p><b>Family:</b> %s</b></p>") % family +
                 _("<p><b>Specimen for %s</b></p>") % script +
                 "<center>" +
                 (specimen_ok ? "<img src=\"#{@tmp_dir}/#{generic_alias}.png\"/>" 
                              : _("<p>No specimen available " \
                                  "for this font and script.</p>")) +
                 "</center>"
        else
          # unlikely
          text = _("<b>No script found for %s.</b>") % 
                   @current_families[generic_alias]
        end
        UI.ChangeWidget(Id("rt_specimen_#{generic_alias}"), :Value, text)
    end

    def text_match_preview(family, generic_alias)
      scripts = font_scripts(family)
      text = _("<p><b>Family:</b> %s</p>") % family +
             _("<p><b>Scripts</b><ul>")
      scripts.each do |script, coverage|
        text << "<li>#{script} (#{coverage})</li>"
      end
      text << "</ul></p>"
      UI.ChangeWidget(Id("rt_specimen_#{generic_alias}"), :Value, text)
    end

    def create_pattern_string(generic_alias)
      pattern = @current_families[generic_alias].dup
      if @fcstate.force_aa_off || 
         (@fcstate.force_aa_off_mono && generic_alias == "monospace")
        pattern << ":antialias=0" 
      end
      if @fcstate.force_ah_on
        pattern << ":autohint=1"  
      end
      if @fcstate.force_hintstyle != FontsConfigState::HINT_STYLES[0]
        pattern << ":hintstyle=#{@fcstate.force_hintstyle}" 
      end
      if @fcstate.lcd_filter !=  FontsConfigState::LCD_FILTERS[0]
        pattern << ":lcdfilter=#{@fcstate.lcd_filter}" 
      end
      if @fcstate.subpixel_layout != FontsConfigState::SUBPIXEL_LAYOUTS[0]
        pattern << ":rgba=#{@fcstate.subpixel_layout}" 
      end
      return pattern
    end

    def initialize_specimen_widget(key = nil)
      @fcstate.fpl.keys.each do |generic_alias|
        @current_families[generic_alias] = 
          installed_families_from(@fcstate.fpl[generic_alias])[0]
        @current_families[generic_alias] ||= match_family(generic_alias)
        scripts = font_scripts(@current_families[generic_alias])
        @current_scripts[generic_alias] = scripts.keys[0] 

        if (UI.TextMode)
          text_match_preview(@current_families[generic_alias], generic_alias)
        else
          if (@current_scripts[generic_alias])
            items = scripts.map do |script, coverage|
              Item(Id("#{script}"), "#{script} (#{coverage} %)")
            end
            UI.ChangeWidget(Id("cmb_specimen_scripts_#{generic_alias}"),
                            :Items, items)

            pattern = create_pattern_string(generic_alias)

            specimen_ok = true
            File.open("#{@tmp_dir}/#{generic_alias}.png", "w") do |png|
              specimen_ok = 
                specimen_write(pattern, @current_scripts[generic_alias], png,
                               SPECIMEN_SIZE, SPECIMEN_SIZE)
            end
          else
             UI.ChangeWidget(Id("cmb_specimen_scripts_#{generic_alias}"),
                             :Items, [])
          end
       
          graphic_match_preview(@current_families[generic_alias],
                                @current_scripts[generic_alias], 
                                generic_alias, specimen_ok)
        end
      end

      # folowing widgets exist only in graphical mode
      if (!UI.TextMode)
        UI.ChangeWidget(Id("chkb_specimen_antialiasing"), :Value, 
                        @fcstate.force_aa_off ? false : true )
        UI.ChangeWidget(Id("chkb_specimen_autohinter"), :Value, 
                        @fcstate.force_ah_on ? true : false )
        UI.ChangeWidget(Id("cmb_specimen_hintstyle"), :Value, 
                        @fcstate.force_hintstyle)
        UI.ChangeWidget(Id("cmb_specimen_lcdfilter"), :Value, 
                        @fcstate.lcd_filter)
        UI.ChangeWidget(Id("cmb_specimen_subpixellayout"), :Value, 
                        @fcstate.subpixel_layout)
        UI.ChangeWidget(Id("cmb_specimen_lcdfilter"), :Enabled,
             @fcstate.subpixel_layout != FontsConfigState::SUBPIXEL_LAYOUTS[0])
      end
    end

    def handle_specimen_widget(widget, event)
      # Text mode has read-only preview tab, that can be changed
      # only via Presets button (initialize_specimen_widget is
      # called there) so following is not be needed
      # (handle_specimen_widget should not be called at all).
      # But it can help in the future when some modifying
      # widget would be added.
      if (UI.TextMode)
        return nil # nothing to do nowadays
      end

      @fcstate.force_aa_off = 
        !UI.QueryWidget(Id("chkb_specimen_antialiasing"), :Value)
      @fcstate.force_ah_on = 
        UI.QueryWidget(Id("chkb_specimen_autohinter"), :Value)
      @fcstate.force_hintstyle = 
        UI.QueryWidget(Id("cmb_specimen_hintstyle"), :Value)
      @fcstate.lcd_filter = 
        UI.QueryWidget(Id("cmb_specimen_lcdfilter"), :Value)
      if (event["ID"] == "cmb_specimen_lcdfilter")
        subpixel_freetype_warning
      end
      @fcstate.subpixel_layout = 
        UI.QueryWidget(Id("cmb_specimen_subpixellayout"), :Value)

      @fcstate.fpl.keys.each do |generic_alias|
        @current_scripts[generic_alias] = 
          UI.QueryWidget(Id("cmb_specimen_scripts_#{generic_alias}"), :Value)
        
        pattern = create_pattern_string(generic_alias)

        specimen_ok = true
        File.open("#{@tmp_dir}/#{generic_alias}.png", "w") do |png|
          specimen_ok = 
            specimen_write(pattern, @current_scripts[generic_alias], png,
                           SPECIMEN_SIZE, SPECIMEN_SIZE)
        end

        graphic_match_preview(@current_families[generic_alias],
                              @current_scripts[generic_alias],
                              generic_alias, specimen_ok)
      end

      UI.ChangeWidget(Id("cmb_specimen_lcdfilter"), :Enabled,
           @fcstate.subpixel_layout != FontsConfigState::SUBPIXEL_LAYOUTS[0])

      return nil
    end

    def installed_families_from(family_list)
      installed = []
      family_list.each do |f|
        if family_installed?(f)
          installed << f
        end
      end
      installed
    end

    def installation_summary_check
      installed = Hash.new
      not_installed_for_aliases = []
      @fcstate.fpl.keys.each do |generic_alias|
        installed[generic_alias] = 
          installed_families_from(@fcstate.fpl[generic_alias])
        if (installed[generic_alias].empty? &&
             !@fcstate.fpl[generic_alias].empty?)
          not_installed_for_aliases << generic_alias
        end
      end
      unless not_installed_for_aliases.empty? then
        text = _("Family preference list for %s\n" \
               "do not contain any installed family.\n\n") %
               not_installed_for_aliases.join(", ") +
               _("Please make sure to install at least one for each\n" \
                 "alias, otherwise this preference setting has " \
                 "no effect.\n\n") +
               _("Fonts can be installed e. g. via fontinfo.opensuse.org. \n" \
                 "If you install them when this yast module is running,\n" \
                 "reread the profile to see results.\n")
        summary = ""
        if (UI.TextMode)
          # <table> do not work for text mode
          @fcstate.fpl.keys.each do |generic_alias|
            summary << "<h3>#{generic_alias}</h3><ul>"
            @fcstate.fpl[generic_alias].each do |f|
              indication = family_installed?(f) ?
                           "installed" : "not installed"
              summary << "<li>#{f} (#{indication})</li>"
            end
            summary << "</ul>"
          end
        else
          summary << "<table>"
          @fcstate.fpl.keys.each do |generic_alias|
            summary << "<tr><td><h3>#{generic_alias}</h3></td></tr>"
            @fcstate.fpl[generic_alias].each do |f|
              indication = family_installed?(f) ? 
                           "<font color=\"green\">installed</font>" :
                           "<font color=\"red\">not installed</font>"
              summary << "<tr><td>#{f}</td><td>#{indication}</td></tr>"
            end
            summary << "<tr></tr>"
          end
          summary << "</table>"
        end

        fpl_inst_summary_dialog = RichTextDialog.new
        fpl_inst_summary_dialog.run(text, summary)
      end
    end

    def subpixel_freetype_warning
      if (@fcstate.subpixel_layout != FontsConfigState::SUBPIXEL_LAYOUTS[0] &&
          (have_freetype &&
           !have_subpixel_rendering))
        Yast.import "Popup"
        text = _("You have set LCD filter type (%s).") % @fcstate.lcd_filter +
               _(" This needs subpixel rendering capabality\ncompiled" \
                 " in FreeType library.") +
               _(" Unfortunately, we can not ship it due patent reasons.\n") +
               "\n" +
               _("See README.subpixel-patents from yast2-fonts package documentation.\n")
               
        Popup.Warning(text)
      end
    end

    def root_user?
      Process.euid == 0
    end

    def specimen_alias_widget(generic_alias)
      VBox(
        HBox(Left(
               Label(Id("lbl_specimen_#{generic_alias}"), _("Match for %s") % generic_alias)
             ),
             Right( UI.TextMode ? Label("") :
               ComboBox(Id("cmb_specimen_scripts_#{generic_alias}"), Opt(:notify, :immediate), "", [])
             )
        ),
        RichText(Id("rt_specimen_#{generic_alias}"),
                 Opt(:hstretch, :vstretch),
                 "")
      )
    end

    def widgets
      help = FontsConfigDialogHelp.new
      widgets_description = {
        "chkb_antialias" => {
          "widget"        => :checkbox,
          "label"         => _("Font &Antialiasing"),
          "init"          => fun_ref(method(:initialize_antialias_checkbox), 
                                     "void (string)"),
          "opt"           => [ :notify, :immediate ],
          "handle_events" => [ "chkb_antialias" ],
          "handle"        => fun_ref(method(:handle_antialias_checkbox),
                                     "symbol (string, map)"),
          "help"          => help.antialiasing,
        },
        "chkb_antialias_mono" => {
          "widget"        => :checkbox,
          "label"         => _("Antialias Also &Monospaced Fonts"),
          "init"          => fun_ref(method(:initialize_antialias_mono_checkbox), 
                                     "void (string)"),
          "opt"           => [ :notify, :immediate ],
          "handle_events" => [ "chkb_antialias_mono" ],
          "handle"        => fun_ref(method(:handle_antialias_mono_checkbox),
                                     "symbol (string, map)"),
          "no_help"       => true
        },
        "chkb_ah_on" => {
          "widget"        => :checkbox,
          "label"         => _("Force A&utohinting On"),
          "init"          => fun_ref(method(:initialize_ahon_checkbox), 
                                     "void (string)"),
          "opt"           => [ :notify, :immediate ],
          "handle_events" => [ "chkb_ah_on" ],
          "handle"        => fun_ref(method(:handle_ahon_checkbox),
                                     "symbol (string, map)"),
          "help"          => help.hinting
        },
        "cmb_hintstyle" => {
          "widget"        => :combobox,
          "init"          => fun_ref(method(:initialize_hintstyle_combo), 
                                     "void (string)"),
          "opt"           => [ :hstretch, :notify, :immediate ],
          "label"         => _("Force Hint St&yle"),
          "handle_events" => [ "cmb_hintstyle" ],
          "handle"        => fun_ref(method(:handle_hintstyle_combo),
                                     "symbol (string, map)"),
          "no_help"       => true
        },
        "cstm_embedded_bitmaps" => {
          "widget"        => :custom,
          "custom_widget" =>
              Frame(
                _("Embedded Bitmaps"),
                VBox(
                  Left(CheckBox(Id("chkb_ebitmaps_on"), Opt(:notify, :immediate),
                                 _("Use &Embedded Bitmaps"))),
                  RadioButtonGroup(Id("rbg_ebl"),
                    VBox(
                      HBox(
                        HSpacing(3),
                        Left(RadioButton(Id("rbtn_ebl_all"), Opt(:notify, :immediate),
                                         _("All Lan&guages")))
                      ),
                      HBox(
                        HSpacing(3),
                        Left(RadioButton(Id("rbtn_ebl_selected"), Opt(:notify, :immediate),
                                         _("Limit to &Selected Languages")))
                      ),
                    ),
                  ),
                  HBox(
                    HSpacing(6),
                    Label(Id("lbl_ebl"), Opt(:hstretch), ""), 
                    PushButton(Id("btn_select_ebl"), _("&Select"))
                  )
                ),
              ),
          "help"       => help.embedded_bitmaps,
          "init"          => fun_ref(method(:initialize_embeddedbitmaps_widget),
                                     "void (string)"),
          "handle_events" => [ 
              "cstm_embedded_bitmaps", 
              "chkb_ebitmaps_on", 
              "rbtn_ebl_all", 
              "rbtn_ebl_selected", 
              "btn_select_ebl",
          ],
          "handle"        => fun_ref(method(:handle_embeddedbitmaps_widget),
                                     "symbol (string, map)") 
        },        
        "cmb_lcd_filter" => {
          "widget"        => :combobox,
          "init"          => fun_ref(method(:initialize_lcdfilter_combo), 
                                     "void (string)"),
          "opt"           => [ :hstretch, :notify, :immediate ],
          "label"         => _("LCD &Filter"),
          "handle_events" => [ "cmb_lcd_filter" ],
          "handle"        => fun_ref(method(:handle_lcdfilter_combo),
                                     "symbol (string, map)"),
          "help"          => help.subpixel_rendering
        },
        "cmb_subpixel_layout" => {
          "widget"        => :combobox,
          "init"          => fun_ref(method(:initialize_subpixellayout_combo), 
                                     "void (string)"),
          "opt"           => [ :hstretch, :notify, :immediate ],
          "label"         => _("&Layout"),
          "handle_events" => [ "cmb_subpixel_layout" ],
          "handle"        => fun_ref(method(:handle_subpixellayout_combo),
                                     "symbol (string, map)"),
          "no_help"       => true
        },
        "cstm_generic_aliases" => {
          "widget"        => :custom,
          "custom_widget" => 
            Table(Id("tbl_generic_aliases"),
                  Opt(:immediate, :notify, :keepSorting),
                  Header(_("Alias"), "")),
          "init"        => fun_ref(method(:initialize_genericaliases_table), 
                                   "void (string)"),
          "handle_events" => [ "tbl_generic_aliases" ],
          "handle"      => fun_ref(method(:handle_genericaliases_table),
                                   "symbol (string, map)"),
          "help"        => help.family_preferences
        },
        "cstm_label_family_list" => {
          "widget"        => :custom,
          "custom_widget" => 
            ReplacePoint(Id(:rp_label_family_list), Label("")),
          "no_help"       => true
        },
        "cstm_family_list" => {
          "widget"        => :custom,
          "custom_widget" => 
            VBox(Table(Id("tbl_family_list"),
                        Opt(:notify, :keepSorting),
				Header(_("Font Family"), _("Available"))),
                 HBox(PushButton(Id("btn_remove"), _("Remove")),
                      HStretch(),
                      PushButton(Id("btn_down"), _("Down")),
                      PushButton(Id("btn_up"), _("Up")), 
                      HStretch(),
                      InputField(Id("txt_add_manual"), 
                                 Opt(:notify, :immediate),
                                 "", ""),
                      PushButton(Id("btn_add_manual"),
                                 _("&Add")),
                      PushButton(Id("btn_add_dialog"), 
                                 _("&Installed families...")))
            ),
          "init"        => fun_ref(method(:initialize_familylist_widget), 
                                   "void (string)"),
          "handle_events" => [ "btn_add_dialog", 
                               "btn_add_manual",
                               "txt_add_manual",
                               "btn_up", 
                               "btn_down", 
                               "btn_remove" ],
          "handle"      => fun_ref(method(:handle_familylist_widget),
                                   "symbol (string, map)"),
          "no_help"     => true
        },
        "chkb_search_mc" => {
          "widget"        => :checkbox,
          "label"         => _("Search &Metric Compatible"),
          "opt"           => [ :notify, :immediate ],
          "init"          => fun_ref(method(:initialize_searchmc_checkbox), 
                                     "void (string)"),
          "handle_events" => [ "chkb_search_mc" ],
          "handle"        => fun_ref(method(:handle_searchmc_checkbox),
                                     "symbol (string, map)"),
          "help"          => help.forcing_family_preferences
        },
        "chkb_no_other" => {
          "widget"        => :checkbox,
          "label"         => _("Never use o&ther fonts"),
          "opt"           => [ :notify, :immediate ],
          "init"          => fun_ref(method(:initialize_noother_checkbox), 
                                     "void (string)"),
          "handle_events" => [ "chkb_no_other" ],
          "handle"        => fun_ref(method(:handle_noother_checkbox),
                                     "symbol (string, map)"),
          "no_help"       => true
        },
        "cstm_specimen_widget" => {
          "widget"        => :custom,
          "custom_widget" =>
            VBox(
              HBox(
                 * @fcstate.fpl.keys.map do |generic_alias|
                     specimen_alias_widget(generic_alias)
                 end
              ), UI.TextMode ? Label("") :
              HBox(
                CheckBox(Id("chkb_specimen_antialiasing"), Opt(:notify, :immediate),
                          _("Font &Antialiasing")),
                HStretch(),
                CheckBox(Id("chkb_specimen_autohinter"), Opt(:notify, :immediate),
                          _("Force A&utohinting On")),
                HStretch(),
                ComboBox(Id("cmb_specimen_hintstyle"), Opt(:notify, :immediate), 
                         _("Force Hint St&yle"), FontsConfigState::HINT_STYLES),
                HStretch(),
                ComboBox(Id("cmb_specimen_subpixellayout"), Opt(:notify, :immediate), 
                         _("Subpixel &Rendering"), FontsConfigState::SUBPIXEL_LAYOUTS),
                ComboBox(Id("cmb_specimen_lcdfilter"), Opt(:notify, :immediate), 
                         _("LCD &Filter"), FontsConfigState::LCD_FILTERS),
              ) 
            ),
          "init"          => fun_ref(method(:initialize_specimen_widget),
                                     "symbol (string)"),
          "handle_events" => UI.TextMode ? [] :
                             [ "chkb_specimen_antialiasing",
                               "chkb_specimen_autohinter",
                               "cmb_specimen_hintstyle",
                               "cmb_specimen_lcdfilter",
                               "cmb_specimen_subpixellayout",
                               * @fcstate.fpl.keys.map do |generic_alias|
                                   "cmb_specimen_scripts_#{generic_alias}"
                                 end ],
          "handle"        => fun_ref(method(:handle_specimen_widget),
                                     "symbol (string, map)"),
          "help"          => help.match_preview
        }
      }

      tabs_description = {
        "algorithms" => {
          "header"       => _("&Rendering Details"),
          "contents"     => 
            VBox(
              Frame(
                _("Antialiasing"),
                VBox(
                  Left("chkb_antialias"),
                  Left(HBox(HSpacing(4), "chkb_antialias_mono"))
                ),
              ),
              Frame(
                _("Hinting"),
                VBox(
                  Left("chkb_ah_on"),
                  Left("cmb_hintstyle")
                ),
              ),
              "cstm_embedded_bitmaps",
              Frame(
                _("Subpixel Rendering"),
                VBox(
                  Left("cmb_subpixel_layout"),
                  Left("cmb_lcd_filter"),
                ),
              ),
              VStretch()
            ),
          "widget_names" => [
            "chkb_antialias",
            "chkb_antialias_mono",
            "chkb_ah_on",
            "cmb_hintstyle",
            "cstm_embedded_bitmaps",
            "cmb_subpixel_layout",
            "cmb_lcd_filter",
          ],
        },
        "families"   => {
          "header"       => _("Prefered &Families"),
          "contents"     => 
            VBox(
              HBox("cstm_generic_aliases", 
                   VBox(Left("cstm_label_family_list"),
                        Left("cstm_family_list"))),
              Frame(
                _("Forcing Family Preferences"),
                VBox(
                  Left("chkb_search_mc"),
                  Left("chkb_no_other")
                )
              )
            ),
          "widget_names" => [
            "cstm_generic_aliases",
            "cstm_label_family_list",
            "cstm_family_list",
            "chkb_search_mc",
            "chkb_no_other"
          ]
        },
        "specimens" => {
          "header"       => _("Match &Preview"),
          "contents"     => VBox("cstm_specimen_widget"),
          "widget_names" => ["cstm_specimen_widget", 
                             * widgets_description["cstm_specimen_widget"]["handle_events"]]
        }
      }

      widgets_description["tabs_fonts_configuration"] = CWMTab.CreateWidget(
          {
            "tab_order"    => ["specimens", "families", "algorithms"],
            "tabs"         => tabs_description,
            "widget_descr" => widgets_description,
            "initial_tab"  => "specimens"
          }
        )

      widgets_description["btn_presets"] = {
          "widget"        => :menu_button,
          "opt"           => [ :notify, :immediate ],
          "label"         => _("&Presets"),
          "items"         => FontsConfigState::preset_list,
          "handle"        => fun_ref(method(:handle_presets_button),
                                     "symbol (string, map)"),
          "help"          => help.font_configuration_module
        }
  
      widgets_description
    end

    # create copy of system settings; remove fonts-config generated
    # config files to have such fontconfig setup as fonts-config 
    # would never run; point fontconfig to this configuration
    def create_default_fontconfig
      family_list_file = FontsConfigCommand.local_family_list_file
      rendering_file = FontsConfigCommand.rendering_config
      metric_bw_symlink = FontsConfigCommand.metric_compatibility_bw_symlink
      metric_avail = FontsConfigCommand.metric_compatibility_avail
      metric_symlink = FontsConfigCommand.metric_compatibility_symlink

      mkdir_p("#{@tmp_dir}#{@fontconfig_path}")
      Dir.glob("#{@fontconfig_path}/*") {|f|
        cp_r(File.expand_path(f), "#{@tmp_dir}#{@fontconfig_path}")
      }

      rm_f("#{@tmp_dir}#{family_list_file}")
      rm_f("#{@tmp_dir}#{rendering_file}")
      rm_f("#{@tmp_dir}#{metric_bw_symlink}")
      ln_sf("#{metric_avail}", "#{@tmp_dir}#{metric_symlink}")

      ENV['FONTCONFIG_PATH'] = "#{@tmp_dir}#{@fontconfig_path}"
    end

    def disable_default_fontconfig
      ENV['FONTCONFIG_PATH'] = nil
    end

    def run_dialog
      Yast.import "UI"
      Yast.import "CWM"
      Yast.import "CWMTab"
      Yast.import "HTML"
      Yast.import "Icon"
      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "Progress"

      widgets_description = widgets
      sysconfig_file = FontsConfigCommand::sysconfig_file

      y2milestone("module started")
      Wizard.CreateDialog

      Progress.New(
        _("Reading Font Configuration"),
        " ",
        1,
        [ _("Read sysconfig file") ],
        [ _("Reading %s...") % sysconfig_file ],
        ""
      )

      Progress.NextStage
      y2milestone("reading #{sysconfig_file}")
      @fcstate.read
      y2milestone("read: " + @fcstate.to_s)
      Progress.Finish

      y2milestone("creating temporary default fontconfig in #{@tmp_dir}")
      create_default_fontconfig

      y2milestone("running dialog")
      ret = CWM.ShowAndRun(
        {
          "widget_names"       => [ "btn_presets", "tabs_fonts_configuration" ],
          "widget_descr"       => widgets_description,
          "contents"           => VBox(HBox(HStretch(), "btn_presets"),
                                  "tabs_fonts_configuration"),
          "caption"            => _("Font Configuration") +  
                                  (root_user? ? "" : _(" (User Mode)")),
          "next_button"        => Label.OKButton,
          "abort_button"       => Label.AbortButton,
          # misuse back_button a bit
          "back_button"        => (root_user? || !File.exists?(FontsConfigCommand.user_sysconfig_file) ? 
                                     nil : _("&Use system settings")),
        }
      )

      y2milestone("disabling temporary default fontconfig")
      disable_default_fontconfig     
      remove_entry_secure(@tmp_dir)
 
      case ret
        when :next
          y2milestone("saving configuration")
          Progress.New(
            _("Writing Font Configuration"),
            " ",
            2,
            [ _("Write sysconfig file"),
              _("Run fonts-config") ],
            [ _("Writing %s...") %  sysconfig_file,
              _("Running fonts-config...") ],
            ""
          )

          Progress.NextStage 
          y2milestone("writing #{sysconfig_file}")
          @fcstate.write
          y2milestone("written: " + @fcstate.to_s)
          Progress.NextStage
          y2milestone("running fonts-config")
          FontsConfigCommand::run_fonts_config(root_user? ? "" : "--user")
          Progress.Finish
          y2milestone("module finished")
        when :abort
          y2milestone("aborted, do not save configuration")
        when :back
          # we are in user mode
          Yast.import "Popup"
          text = _("This will irrecoverably remove user setting done previously " +
                   "with this module.")
          if (Popup.YesNo(text))
            FontsConfigCommand::run_fonts_config("--remove-user-setting")
            y2milestone("remove user setting")
          end
      end
      Wizard.CloseDialog
    end
  end

  class FontsConfigDialogHelp
    include Yast
    include UIShortcuts
    include I18n

    def initialize
      textdomain "fonts"

      Yast.import "UI"
      @fcstate = FontsConfigState.new
      @fcstate.load_preset("default")
    end

    def font_configuration_module
      Yast.import "String"
      presets = FontsConfigState::PRESETS
      _("<h1>Font Configuraution Module</h1>") +
      _("<p>Module to control <b>system wide</b> or <b>user</b> font rendering setting.</p>") +
      _("<i>Distribution default</i> is font setting shipped on media and " +
        "it is that one almost same for years (not counting decisions of individual DE). ") +
      _("This setting can be changed:<ul>") +
      _("<li>system wide when module is run with <tt>root</tt> credentials "+
        "to create <i>system setting.</i> ") +
      _("System, where font module never run or <b>Default</b> preset was chosen, " + 
        "uses distribution default.</li>") +
      _("<li>for <i>user setting</i> when module is run as ordindary user. ") +
      _("User, which never run this module or chooses to <b>Use system settings</b>, uses system settings. ") +
      _("User, which chooses <b>Default</b> preset, uses distribution default.</li></ul>") +
      _("<p><b>NOTE:</b> ") + 
      _("In general, it is not recommended to combine font module user mode with other font setting. ") +
      _("Nevertheless, setting in <tt>~/.config/fontconfig/fonts.conf</tt> " +
        "should always have precendence before arbitrary font module setting.</p>") +
      _("<p>Help for <i>Presets</i> button and for the current tab follows.</p>") +
      _("<p><b>Presets</b> button serves a possibility to choose predefined profiles: <ul>") +
      presets.keys.drop(1).map do |preset|
        _("<li><b>%{name}: </b>%{help}</li>") % {
            :name => _(presets[preset]["name"]),
            :help => _(presets[preset]["help"])
        }
      end.join + "</ul>" +
      _("Every single menu item there just fills appropriate setting in all tabs. " \
        "That setting can be later arbitrarily customized in depth by respective " \
        "individual fields of corresponding tabs.</p>")
    end

    def match_preview
      _("<h2>Match Preview Tab</h2>") +
      _("<p>In this paragraph, <i>current setting</i> means setting " \
        "of the system plus changes made in currently running fonts module.</p>") +
      _("<p>Matches to system generic aliases can be seen in this initial tab. ") +
      _("In other words, for every alias (%s) you can see family name, which" \
        " resolves to given alias according to <i>current setting.</i></p>" \
        "") % @fcstate.fpl.keys.join(", ") +
      _("<p>In adition to that, graphical mode allows to display " \
        "font specimen of the matched font rendered (again) taking " \
        "<i>current setting</i> into account. ") +
      _("In the corresponding combo box, script coverage of matched font " \
        "can be seen and specimen string for given script can be chosen.</p>") +
      _("<p>At the bottom, there are crucial rendering options duplicated " \
        "from Rendered Details Tab, " \
        "which can be used to see changes in the rendering on the fly.</p>")
    end

    def antialiasing
      _("<h2 id=\"tab_help\">Rendering Details Tab</h2>") +
      _("<p>This tab controls <b>how</b> fonts are rendered." \
        " It allows you to amend font rendering algorithms to be used " \
        "and change their options.</p>") +
      _("<h3>Antialiasing</h3>") +
      _("<p>By default, all outline fonts are smoothed by method called " \
        "<i>antialiasing.</i>") +
      _(" Black and white rendering can be forced for all fonts or for " \
        "monospaced only.</p>") +
      _("<p>See: %s<\p>") % "<i>Wikipedia: Font Rasterization</i>"
    end

    def hinting
      _("<h3>Hinting</h3>") +
      _("<p>Hinting instructions helps rasterizer to fit glyphs stems " \
        "to the grid.</p>") +
      _("<p>In the default setting, FreeType's autohinter can be used " \
        "depending on font type and quality of own instructions." \
        " Use of autohinter can be forced by <b>Force Autohinting On</b> " \
        "option.</p>") +
      _("<p>For each hinting algorithm, hint style (hinting level) is chosen.") +
      _(" It is possible to set hint style globally by <b>Force Hint Style</b> " \
        "option.</p>") +
      _("<p>See: %s<\p>") % "<i>Wikipedia: Font Rasterization, Font hinting</i>"
    end

    def embedded_bitmaps
      _("<h3>Embedded Bitmaps</h3>") +
      _("<p>Some outline fonts contain so called bitmap strikes, i. e. bitmap" \
        " version of given font for certain sizes." \
        " In this section it can be turned off entirely, on only for fonts which" \
        " cover specified languages, or on for every font.")
    end

    def subpixel_rendering  
      _("<h3>Subpixel Rendering</h3>") +
      _("<p>Subpixel rendering multiples resolution in one direction by using " \
        "colour primaries (subpixels) of an LCD display.</p>") +
      _("<p>Choose LCD filter, which should be used, and subpixel layout " \
        "corresponding to display and its rotation.</p>") +
      _("<p>Note, that due to patent reasons, FreeType has subpixel " \
         "rendering turned off by default.") +
      _(" Without FreeType's subpixel rendering support compiled in, " \
        "setting in this section has no effect.</p>") +
      _("<p>See: %s<\p>") % "<i>Wikipedia: Subpixel rendering</i>"
    end

    def family_preferences
      _("<h2>Prefered Families Tab</h2>") +
      _("<p>This tab controls <b>which</b> fonts are rendered.</p>") +
      _("<h3>Preference Lists</h3>") +
      _("<p>Here, Family Preference Lists (FPL) for generic aliases (%s) " \
        "can be defined.") % @fcstate.fpl.keys.join(', ') +
      _(" These are sorted lists of family names, with most prefered " \
        "family first.") +
      _(" There is default (system-wide) FPL yet defined for each generic alias.") +
      _(" FPLs defined in this dialog will be prepended to them.</p>") +
      _("<p>System will look for the first <b>installed</b> family in the list," \
        " other query elements taking into account of course. Available font" \
        " packages for SUSE distributions can be" \
        " browsed and installed from <b>fontinfo.opensuse.org.</b></p>")
    end

    def forcing_family_preferences
      _("<h3>Forcing Family Preferences</h3>") +
      _("<p>In some circumstances, FPLs defined in this dialog are " \
        "not taken into account." \
        " Following two options strenghten their role.</p>") +
      _("<h4>Search Metric Compatible</h4>") +
      _("<p>Two fonts are metric compatible, when all corresponding letters" \
        " are of the same size. That implies, document displayed using these" \
        " fonts has the same same size too, same line wraps etc.</p>") +
      _("<p>Via default setting, system substitutes metric compatible fonts preferably," \
        " and FPLs defined in this dialog can be circumvented by this rule.</p>") +
      _("<p>Where metric compatibility does not matter, this option can be unchecked.</p>") +
      _("<h4>Never use other fonts</h4>") +
      _("<p>When checked, this option introduces very strong position for here" \
        " defined preference lists. It pushes families from there before" \
        " document or GUI requests, if they cover required charset.</p>")
    end
  end
end
