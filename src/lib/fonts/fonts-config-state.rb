require "yast"

module FontsConfig
  class FontsConfigState
    include Yast
    extend Yast::I18n

    HINT_STYLES = [
      "none",
      "hintnone",
      "hintslight",
      "hintmedium",
      "hintfull"
    ]

    LCD_FILTERS = [
      "lcdnone",
      "lcddefault",
      "lcdlight",
      "lcdlegacy"
    ]

    SUBPIXEL_LAYOUTS = [
      "none",
      "rgb",
      "vrgb",
      "bgr",
      "vbgr",
      "unknown"
    ]

    # in case of changing profiles, please reflect
    # edits in test/data/sysconfig.fonts-config.*
    # otherwise testsuite will fail
    PRESETS = {
        "unset" => {
          "name" => N_("Unset"),
          "fpl" => {
            "sans-serif" => nil,
            "serif" => nil,
            "monospace" => nil,
          },
          "search_metric_compatible" => nil,
          "really_force_fpl" => nil,
          "force_aa_off" => nil,
          "force_aa_off_mono" => nil,
          "force_ah_on" => nil,
          "force_hintstyle" => nil,
          "embedded_bitmaps" => nil,
          "all_ebl" => nil,
          "ebl" => nil,
          "lcd_filter" => nil,
          "subpixel_layout" => nil,
        },
        "bitmap_fonts" => {
          "name" => N_("Bitmap Fonts"),
          "fpl" =>  {
            "sans-serif" => [
              "Adobe Helvetica",
              "B&H Lucida",
              "Efont Biwidth",
              "Efont Fixed",
              "Efont Fixed Wide",
              "Arabic Newspaper",
              "Gnu Unifont",
              "WenQuanYi WenQuanYi Bitmap Song",
            ],
            "serif" => [
              "Adobe Times",
              "Adobe New Century Schoolbook",
              "Adobe Utopia",
              "B&H LucidaBright",
              "MUTT ClearlyU Wide",
              "MUTT ClearlyU PUA",
              "MUTT ClearlyU Alternate Glyphs Wide",
            ],
            "monospace" => [
              "Misc Fixed",
              "Misc Fixed Wide",
              "Adobe Courier",
              "B&H LucidaTypewriter",
              "Efont Fixed",
              "Efont Fixed Wide",
              "Gnu Unifont Mono",
              "Schumacher Clean",
              "xos4 Terminus",
              "WenQuanYi WenQuanYi Bitmap Song",
            ],
          },
          "search_metric_compatible" => true,
          "really_force_fpl" => false,
          "force_aa_off" => false,
          "force_aa_off_mono" => false,
          "force_ah_on" => false,
          "force_hintstyle" => HINT_STYLES[0],
          "embedded_bitmaps" => true,
          "all_ebl" => true,
          "ebl" => [ ],
          "lcd_filter" => LCD_FILTERS[0],
          "subpixel_layout" => SUBPIXEL_LAYOUTS[0],
        },
        "bw_fonts" => {
          "name" => N_("Black and White Rendering"),
          "fpl" =>  {
            "sans-serif" => [],
            "serif" => [],
            "monospace" => [],
          },
          "search_metric_compatible" => true,
          "really_force_fpl" => false,
          "force_aa_off" => true,
          "force_aa_off_mono" => false,
          "force_ah_on" => false,
          "force_hintstyle" => HINT_STYLES[0],
          "embedded_bitmaps" => true,
          "all_ebl" => false,
          "ebl" => [ "ja", "ko", "zh" ],
          "lcd_filter" => LCD_FILTERS[0],
          "subpixel_layout" => SUBPIXEL_LAYOUTS[0],
        },
        "bw_mono_fonts" => {
          "name" => N_("Black and White Rendering for Monospace Fonts"),
          "fpl" =>  {
            "sans-serif" => [],
            "serif" => [],
            "monospace" => [],
          },
          "search_metric_compatible" => true,
          "really_force_fpl" => false,
          "force_aa_off" => false,
          "force_aa_off_mono" => true,
          "force_ah_on" => false,
          "force_hintstyle" => HINT_STYLES[0],
          "embedded_bitmaps" => true,
          "all_ebl" => false,
          "ebl" => [ "ja", "ko", "zh" ],
          "lcd_filter" => LCD_FILTERS[0],
          "subpixel_layout" => SUBPIXEL_LAYOUTS[0],
        },
        "default" => {
          "name" => N_("Default"),
          "fpl" =>  {
            "sans-serif" => [],
            "serif" => [],
            "monospace" => [],
          },
          "search_metric_compatible" => true,
          "really_force_fpl" => false,
          "force_aa_off" => false,
          "force_aa_off_mono" => false,
          "force_ah_on" => false,
          "force_hintstyle" => HINT_STYLES[0],
          "embedded_bitmaps" => true,
          "all_ebl" => false,
          "ebl" => [ "ja", "ko", "zh" ],
          "lcd_filter" => LCD_FILTERS[0],
          "subpixel_layout" => SUBPIXEL_LAYOUTS[0],
        },
        "cff_fonts" => {
          "name" => N_("CFF Fonts"),
          "fpl" =>  {
            "sans-serif" => [
              "Source Sans Pro",
              "CMU Sans Serif",
              "CMU Bright",
              "Linux Biolinum O",
              "Latin Modern Sans",
            ],
            "serif" => [
              "Source Serif Pro",
              "CMU Serif",
              "CMU Serif Extra",
              "Linux Libertine O",
              "Crimson",
              "Old Standard",
              "Rachana",
              "Latin Modern Roman",
            ],
            "monospace" => [
              "Source Code Pro",
              "CMU Typewriter Text",
              "Linux Libertine Mono O",
              "Tempora",
              "Latin Modern Mono",
              "Latin Modern Mono Light",
            ],
          },
          "search_metric_compatible" => true,
          "really_force_fpl" => false,
          "force_aa_off" => false,
          "force_aa_off_mono" => false,
          "force_ah_on" => false,
          "force_hintstyle" => HINT_STYLES[0],
          "embedded_bitmaps" => true,
          "all_ebl" => false,
          "ebl" => [ "ja", "ko", "zh" ],
          "lcd_filter" => LCD_FILTERS[0],
          "subpixel_layout" => SUBPIXEL_LAYOUTS[0],
        },
        "autohinter" => {
          "name" => N_("Exclusive Autohinter Rendering"),
          "fpl" =>  {
            "sans-serif" => [],
            "serif" => [],
            "monospace" => [],
          },
          "search_metric_compatible" => true,
          "really_force_fpl" => false,
          "force_aa_off" => false,
          "force_aa_off_mono" => false,
          "force_ah_on" => true,
          "force_hintstyle" => HINT_STYLES[0],
          "embedded_bitmaps" => true,
          "all_ebl" => false,
          "ebl" => [ "ja", "ko", "zh" ],
          "lcd_filter" => LCD_FILTERS[0],
          "subpixel_layout" => SUBPIXEL_LAYOUTS[0],
        },
      }

    # fpl ~ family preference lists
    attr_accessor :fpl
    attr_accessor :search_metric_compatible
    attr_accessor :really_force_fpl

    attr_accessor :force_aa_off
    attr_accessor :force_aa_off_mono
    attr_accessor :force_ah_on
    attr_accessor :force_hintstyle
    attr_accessor :embedded_bitmaps
    attr_accessor :all_ebl
    attr_accessor :ebl
    attr_accessor :lcd_filter
    attr_accessor :subpixel_layout

    # for testsuite
    def self.presets
      PRESETS
    end

    def initialize
      load_preset("unset")
    end
  
    # create list of preset [key, name] pairs
    def self.preset_list
      PRESETS.keys.drop(1).map do |preset|
         [ preset, _(PRESETS[preset]["name"]) ]
       end
    end

    def self.is_preset(key)
      PRESETS.keys.index(key)
    end

    def load_preset(preset)
      @fpl = deep_copy(PRESETS[preset]["fpl"])
      @search_metric_compatible = PRESETS[preset]["search_metric_compatible"]
      @really_force_fpl = PRESETS[preset]["really_force_fpl"]

      @force_aa_off  = PRESETS[preset]["force_aa_off"]
      @force_aa_off_mono = PRESETS[preset]["force_aa_off_mono"] 
      @force_ah_on = PRESETS[preset]["force_ah_on"]
      @force_hintstyle = PRESETS[preset]["force_hintstyle"]
      @embedded_bitmaps = PRESETS[preset]["embedded_bitmaps"]
      @all_ebl = PRESETS[preset]["all_ebl"]
      @ebl = PRESETS[preset]["ebl"]
      @lcd_filter = PRESETS[preset]["lcd_filter"]
      @subpixel_layout = PRESETS[preset]["subpixel_layout"]
   end

   def to_s
     "fpl[sans]=" + @fpl["sans-serif"].join(':') +
     ",fpl[serif]=" + @fpl["serif"].join(':') +
     ",fpl[monospace]=" + @fpl["monospace"].join(':') +
     ",search_metric_compatible=" + @search_metric_compatible.to_s +
     ",really_force_fpl=" + @really_force_fpl.to_s +
     ",force_aa_off=" + @force_aa_off.to_s +
     ",force_aa_off_mono=" + @force_aa_off_mono.to_s +
     ",force_ah_on=" + @force_ah_on.to_s +
     ",force_hintstyle=" + @force_hintstyle +
     ",embedded_bitmaps=" + @embedded_bitmaps.to_s +
     ",all_ebl=" + @all_ebl.to_s +
     ",ebl=" + @ebl.join(':') +
     ",lcd_filter=" + @lcd_filter.to_s +
     ",subpixel_layout=" + @subpixel_layout
   end

   def write(sc_path)
      temp = @fpl["sans-serif"].join(':')
      SCR.Write(
        path(sc_path + ".PREFER_SANS_FAMILIES"),
        temp
      )

      temp = @fpl["serif"].join(':')
      SCR.Write(
        path(sc_path + ".PREFER_SERIF_FAMILIES"),
        temp
      )

      temp = @fpl["monospace"].join(':')
      SCR.Write(
        path(sc_path + ".PREFER_MONO_FAMILIES"),
        temp
      )
        
      temp = @search_metric_compatible ? "yes" : "no"
      SCR.Write(
        path(sc_path + ".SEARCH_METRIC_COMPATIBLE"),
        temp
      )

      temp = @really_force_fpl ? "yes" : "no"
      SCR.Write(
        path(sc_path + ".FORCE_FAMILY_PREFERENCE_LISTS"),
        temp
      )

      temp = @force_aa_off ? "yes" : "no"
      SCR.Write(
        path(sc_path + ".FORCE_BW"),
        temp
      )
      
      temp = @force_aa_off_mono ? "yes" : "no"
      SCR.Write(
        path(sc_path + ".FORCE_BW_MONOSPACE"),
        temp
      )
    
      temp = @force_ah_on ? "yes" : "no"
      SCR.Write(
        path(sc_path + ".FORCE_AUTOHINT"),
        temp
      )

      SCR.Write(
        path(sc_path + ".FORCE_HINTSTYLE"),
        @force_hintstyle
      )

      # don't use embedded bitmaps when 'Use Embedded Bitmaps' is 
      # not checked or (Limit to Selected Languages is checked but
      # the list is empty -- empty string would mean 'ALL')
      temp = !@embedded_bitmaps || (!@all_ebl && @ebl.empty?) ? "no" : "yes"
      SCR.Write(
        path(sc_path + ".USE_EMBEDDED_BITMAPS"),
        temp
      )

      if @all_ebl
        temp = ""
      else
        temp = @ebl.join(':')
      end
      SCR.Write(
        path(sc_path + ".EMBEDDED_BITMAPS_LANGUAGES"),
        temp 
      );

      SCR.Write(
        path(sc_path + ".USE_LCDFILTER"),
        @lcd_filter
      )

      SCR.Write(
        path(sc_path + ".USE_RGBA"),
        @subpixel_layout
      )

   end

   def read(sc_path)
      temp = SCR.Read(
              path(sc_path + ".PREFER_SANS_FAMILIES")
             )
      @fpl["sans-serif"] = temp.split(':')

      temp = SCR.Read(
              path(sc_path + ".PREFER_SERIF_FAMILIES")
             )
      @fpl["serif"] = temp.split(':')

      temp = SCR.Read(
              path(sc_path + ".PREFER_MONO_FAMILIES")
             )
      @fpl["monospace"] = temp.split(':')

      temp = SCR.Read(
               path(sc_path + ".SEARCH_METRIC_COMPATIBLE"),
             )
      @search_metric_compatible = temp == "yes"

      temp = SCR.Read(
               path(sc_path + ".FORCE_FAMILY_PREFERENCE_LISTS"),
             )
      @really_force_fpl = temp == "yes"

      temp = SCR.Read(
               path(sc_path + ".FORCE_BW"),
             )
      @force_aa_off = temp == "yes"

      temp = SCR.Read(
               path(sc_path + ".FORCE_BW_MONOSPACE"),
             )
      @force_aa_off_mono = temp == "yes"

      temp = SCR.Read(
               path(sc_path + ".FORCE_AUTOHINT"),
             )
      @force_ah_on = temp == "yes"

      @force_hintstyle = SCR.Read(
                           path(sc_path + ".FORCE_HINTSTYLE"),
                         )

      temp = SCR.Read(
               path(sc_path + ".USE_EMBEDDED_BITMAPS")
             )
      @embedded_bitmaps = temp == "yes"

      temp = SCR.Read(
              path(sc_path + ".EMBEDDED_BITMAPS_LANGUAGES")
             )
      if (temp == "")
        @all_ebl = true
        @ebl = []
      else
        @all_ebl = false
        @ebl = temp.split(':')
      end

      @lcd_filter = SCR.Read(
                      path(sc_path + ".USE_LCDFILTER"),
                    )

      @subpixel_layout = SCR.Read(
                           path(sc_path + ".USE_RGBA"),
                         )
   end
  end
end

