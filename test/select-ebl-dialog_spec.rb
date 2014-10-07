require_relative "spec-helper"
require "fonts/select-ebl-dialog"
require "yast"

describe FontsConfig::Languages do
  describe "#languages" do
    it "returns hash ISO 639-1 code -> language" do
      lgs = FontsConfig::Languages.languages
      expect(lgs).to be_a(Hash)
      # just some examples
      expect(lgs["ab"]).to eq "Abkhazian"
      expect(lgs["zu"]).to eq "Zulu"
      expect(lgs["ii"]).to eq "Sichuan Yi"
      expect(lgs["sh"]).to eq "Serbo-Croatian"
      expect(lgs["zh-SG"]).to eq "Chinese (Singapore)"
      expect(lgs["to"]).to eq "Tonga (Tonga Islands)"
      expect(lgs["nb"]).to eq "Norwegian Bokmål"
    end
  end
  describe "#names" do
    it "returns list of names for given ISO 639-1 codes" do
      lgs = FontsConfig::Languages.languages
      codes = lgs.keys
      names = lgs.values
      expect(names == FontsConfig::Languages.names(codes))
    end
  end
end

describe FontsConfig::SelectEBLDialog do
  include Yast::UIShortcuts

  def mock_dialog(input, selected_languages)
    ui = double("Yast::UI")
    stub_const("Yast::UI", ui)

    expect(ui).to receive(:CloseDialog).
      and_return(true)

    expect(ui).to receive(:OpenDialog).
      and_return(true)

    expect(ui).to receive(:UserInput).
      and_return(input)

    if (input == "btn_ok")
      expect(ui).to receive(:QueryWidget).
        with(Id("mchkb_languages"), :SelectedItems).
        and_return(selected_languages)
    end
  end

  it "returns no languages when no languages was selected (both before dialog run and in the dialog)" do
    ebld = FontsConfig::SelectEBLDialog.new
    mock_dialog("btn_ok", [])
    expect(ebld.run([])).to eq []
  end
  it "returns languages selected before dialog run when no changes made" do
    ebld = FontsConfig::SelectEBLDialog.new
    mock_dialog("btn_ok", ["ab", "zh-SG", "zu"])
    expect(ebld.run(["ab", "zh-SG", "zu"])).to eq ["ab", "zh-SG", "zu"]
  end
  it "returns languages selected in the dialog" do
    ebld = FontsConfig::SelectEBLDialog.new
    mock_dialog("btn_ok", ["rw", "zh-SG", "mt", "ms"])
    expect(ebld.run(["ab", "zh-SG", "zu"])).to eq ["rw", "zh-SG", "mt", "ms"]
  end
  it "returns languages selected before dialog run when dialog canceled" do
    ebld = FontsConfig::SelectEBLDialog.new
    mock_dialog("btn_cancel", ["rw", "zh-SG", "mt", "ms"])
    expect(ebld.run(["ab", "zh-SG", "zu"])).to eq ["ab", "zh-SG", "zu"]
  end
end

