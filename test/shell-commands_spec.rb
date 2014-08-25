require_relative "spec-helper"
require "fonts/shell-commands"

describe FontsConfig::FontconfigCommands do
  def are_installed(families)
    for family in families do
      if (!FontsConfig::FontconfigCommands::is_family_installed(family))
        return false
      end
    end
    return true
  end

  def an_installed_family
    return FontsConfig::FontconfigCommands::installed_families("family")[0]    
  end

  def contain_pattern_entries(families, entries)
    entries.delete("family")
    for family in families do
      for entry in entries do
        if (!family.include?(entry + "="))
          return false
        end
      end
    end
    return true
  end

  describe "#is_family_installed" do
    it "returns false when family is not installed" do
      family = FontsConfig::FontconfigCommands::is_family_installed("foo")
      expect(family).to be false
    end
  end

  describe "#installed_families" do
    it "returns non empty list of installed families" do
      families = FontsConfig::FontconfigCommands::installed_families("family")
      expect(families).to be_a(Array)
      expect(families.length).to be > 0
      expect(are_installed(families)).to be true
    end
  end

  describe "#is_family_installed" do
    it "returns true when family is installed" do
      expect(FontsConfig::FontconfigCommands::is_family_installed(an_installed_family()))
    end    
  end

  describe "#installed_families" do
    it "understands important fontconfig pattern entries" do
      entries = ["family", "fontformat"]
      families = FontsConfig::FontconfigCommands::installed_families(entries.join(" "))
      expect(contain_pattern_entries(families, entries)).to be true
    end
  end
end

describe FontsConfig::FontsConfigCommand do
  describe "#run_fonts_config" do    
    it "raises error when not run under root" do
      if (Process.uid != 0)
        expect{FontsConfig::FontsConfigCommand::run_fonts_config}.to raise_error
      end
    end
    it "raises no error when run under root" do
      if (Process.uid == 0)
        expect{FontsConfig::FontsConfigCommand::run_fonts_config}.not_to raise_error
      end
    end
  end
end

