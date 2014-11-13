require_relative "spec-helper"
require "yast/fontconfig_setting"

describe FontconfigSetting do
  include FontconfigSetting

  def are_installed(families)
    families.each do |family|
      if (!family_installed?(family))
        return false
      end
    end
    return true
  end

  def an_installed_family
    return installed_families(["family"])[0]    
  end

  def contain_pattern_entries(families, entries)
    entries.delete("family")
    families.each do |family|
      entries.each do |entry|
        if (!family.include?(entry + "="))
          return false
        end
      end
    end
    return true
  end

  describe "#family_installed?" do
    it "returns false when family is not installed" do
      family = family_installed?("foo")
      expect(family).to be false
    end

    it "returns true when family is installed" do
      expect(family_installed?(an_installed_family))
    end    
  end

  describe "#installed_families" do
    it "returns non empty list of installed families" do
      families = installed_families(["family"])
      expect(families).to be_a(Array)
      expect(families.length).to be > 0
      expect(are_installed(families)).to be true
    end

    it "understands important fontconfig pattern entries" do
      entries = ["family", "fontformat"]
      families = installed_families(entries)
      expect(contain_pattern_entries(families, entries)).to be true
    end
  end

  describe "#match_family" do
    it "returns a installed family for sans-serif alias" do
      family = match_family("sans-serif")
      expect(are_installed([family])).to be true
    end

    it "returns a installed family for serif alias" do
      family = match_family("serif")
      expect(are_installed([family])).to be true
    end

    it "returns a installed family for monospace alias" do
      family = match_family("monospace")
      expect(are_installed([family])).to be true
    end
  end
end


