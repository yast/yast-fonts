require_relative "spec-helper"
require "yast/fontconfig_setting"

describe FontconfigSetting do
  include FontconfigSetting

  def are_installed(families)
    families.each do |family|
      if (!fc_is_family_installed(family))
        return false
      end
    end
    return true
  end

  def an_installed_family
    return fc_installed_families(["family"])[0]    
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

  describe "#fc_is_family_installed" do
    it "returns false when family is not installed" do
      family = fc_is_family_installed("foo")
      expect(family).to be false
    end

    it "returns true when family is installed" do
      expect(fc_is_family_installed(an_installed_family()))
    end    
  end

  describe "#fc_installed_families" do
    it "returns non empty list of installed families" do
      families = fc_installed_families(["family"])
      expect(families).to be_a(Array)
      expect(families.length).to be > 0
      expect(are_installed(families)).to be true
    end

    it "understands important fontconfig pattern entries" do
      entries = ["family", "fontformat"]
      families = fc_installed_families(entries)
      expect(contain_pattern_entries(families, entries)).to be true
    end
  end
end


