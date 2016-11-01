# encoding: utf-8
#

require_relative "spec-helper"
require "yast/font_specimen"
require "yast/fontconfig_setting"
require "tmpdir"
require "fileutils"

describe FontSpecimen do
  include FontSpecimen
  include FontconfigSetting
  include ::FileUtils

  def an_installed_family
    return installed_families(["family"])[0]    
  end

  describe "#font_scripts" do
    it "returns non empty hash when family is not installed" do
      # in fact, it should every time return non-empty hash
      # iff fontconfig returns anything and that is iff
      # at least one font is installed on the system
      scripts_hash = font_scripts("foo")
      expect(scripts_hash).to be_a(Hash)
      expect(scripts_hash.empty?).to be false
    end

    it "returns non empty hash when family is installed" do
      scripts_hash = font_scripts(an_installed_family())
      expect(scripts_hash).to be_a(Hash)
      expect(scripts_hash.empty?).to be false
    end    
  end

  describe "#specimen_write" do
    it "do not raise and returns true for non negative png dimensions" do
      # it should always return true when there is not an error in environment
      # or error in underlying libraries except that wrong size is given
      family = an_installed_family()
      scripts = font_scripts(family)
      tmp_dir = Dir.mktmpdir("yast-fonts-test-")
      File.open("#{tmp_dir}/#{family}.png", "w") do |png|
        expect(specimen_write(family, scripts.keys[0], png, 50, 50)).to be true
      end
      remove_entry_secure(tmp_dir)
    end    

    it "do not raise but returns fals for negative png dimensions" do
      # it should always return true when there is not an error in environment
      # or error in underlying libraries except that wrong size is given
      family = an_installed_family()
      scripts = font_scripts(family)
      tmp_dir = Dir.mktmpdir("yast-fonts-test-")
      File.open("#{tmp_dir}/#{family}.png", "w") do |png|
        expect(specimen_write(family, scripts.keys[0], png, -1, -1)).to be false
      end
      remove_entry_secure(tmp_dir)
    end    
  end

end


