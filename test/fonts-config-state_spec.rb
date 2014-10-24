require_relative "spec-helper"
require "fonts/fonts-config-state"

describe FontsConfig::FontsConfigState do
  include Yast

  def preset_loaded(fcstate, preset)
    dp = FontsConfig::FontsConfigState::PRESETS[preset]
    return fcstate.fpl == dp["fpl"] &&
           fcstate.search_metric_compatible == dp["search_metric_compatible"] && 
           fcstate.really_force_fpl == dp["really_force_fpl"] &&
           fcstate.force_aa_off == dp["force_aa_off"] &&
           fcstate.force_aa_off_mono == dp["force_aa_off_mono"] &&
           fcstate.force_ah_on == dp["force_ah_on"] &&
           fcstate.force_hintstyle == dp["force_hintstyle"] &&
           fcstate.embedded_bitmaps == dp["embedded_bitmaps"] &&
           fcstate.all_ebl == dp["all_ebl"] &&
           fcstate.lcd_filter == dp["lcd_filter"] && 
           fcstate.subpixel_layout == dp["subpixel_layout"]
  end

  def test_read(preset)
    directory = File.expand_path("../data/sysconfig-examples/#{preset}", __FILE__)
    scr_handle = Yast::WFM.SCROpen("chroot=#{directory}:scr", false)
    raise "Error creating the chrooted scr instance!" if scr_handle < 0
    Yast::WFM.SCRSetDefault(scr_handle)

    fcstate = FontsConfig::FontsConfigState.new
    fcstate.read
    ret = preset_loaded(fcstate, preset) unless preset.nil?

    Yast::WFM.SCRClose(scr_handle) 
    return ret
  end

  def test_write(preset)
    directory = File.expand_path("../data/sysconfig-examples/#{preset}", __FILE__)
    scr_handle = Yast::WFM.SCROpen("chroot=#{directory}:scr", false)
    raise "Error creating the chrooted scr instance!" if scr_handle < 0
    Yast::WFM.SCRSetDefault(scr_handle)

    fcstate = FontsConfig::FontsConfigState.new
    fcstate.load_preset(preset)
    fcstate.write
    fcstate.read
    ret = preset_loaded(fcstate, preset)

    Yast::WFM.SCRClose(scr_handle) 
    return true
  end

  describe "#load_preset" do
    it "loads given preset" do
      fcstate = FontsConfig::FontsConfigState.new
      for k in FontsConfig::FontsConfigState::PRESETS.keys do
        fcstate.load_preset(k)
        preset_loaded(fcstate, k)
      end
    end
  end

  describe "#initialize" do
    it "loads `unset' profile" do
      fcstate = FontsConfig::FontsConfigState.new
      expect(preset_loaded(fcstate, "unset")).to be true
    end
  end

  describe "#preset_list" do
    it "returns list of preset ids" do
      for p in FontsConfig::FontsConfigState::preset_list do
        expect(FontsConfig::FontsConfigState::preset?(p[0])).to be true
      end
    end
  end

  describe "#preset?" do
    it "returns true when argument is a preset" do
      for p in FontsConfig::FontsConfigState::preset_list do
        expect(FontsConfig::FontsConfigState::preset?(p[0])).to be true
      end
    end
  end

  describe "#read" do
    it "reads variables from sysconfig file" do
      for p in FontsConfig::FontsConfigState::preset_list do
        expect(test_read(p[0])).to be true
      end
    end

    it "do not crash on sysconfig file without some of PREFER_*_FAMILIES variables" do
      expect{test_read(nil)}.not_to raise_error
    end
  end

  describe "#write" do
    it "writes variables to sysconfig file" do
      for p in FontsConfig::FontsConfigState::preset_list do
        expect(test_write(p[0])).to be true
      end
    end
  end

end

