require_relative "spec-helper"
require "fonts/shell-commands"

require "yast/scr"
require "yast/path"

describe FontsConfig::FontsConfigCommand do
=begin
  describe "#run_fonts_config" do    
    it "error popup when not run under root" do
      expect(FontsConfig::FontsConfigCommand::run_fonts_config).to be false
    end
  end

  describe "#local_family_list_file" do
    it "returns non-empty string" do
      local_family_list_file = 
        FontsConfig::FontsConfigCommand::local_family_list_file
      expect(local_family_list_file).to be_a(String)
      expect(local_family_list_file.length > 0).to be true
    end
  end

  describe "#sysconfig_file" do
    it "returns non-empty string" do
      sysconfig_file = FontsConfig::FontsConfigCommand::sysconfig_file
      expect(sysconfig_file).to be_a(String)
      expect(sysconfig_file.length > 0).to be true
    end
  end
=end
end

