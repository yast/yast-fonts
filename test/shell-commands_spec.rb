require_relative "spec-helper"
require "fonts/shell-commands"

require "yast/scr"
require "yast/path"

describe FontsConfig::FontsConfigCommand do
  describe "#run_fonts_config" do    
    it "error popup when not run under root" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        expect(FontsConfig::FontsConfigCommand::run_fonts_config).to be false
      end
    end
  end

  describe "#local_family_list_file" do
    it "returns non-empty string" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        local_family_list_file = 
          FontsConfig::FontsConfigCommand::local_family_list_file
        expect(local_family_list_file).to be_a(String)
        expect(local_family_list_file.length > 0).to be true
      end
    end
  end

  describe "#rendering_config" do
    it "returns non-empty string" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        rendering_config = FontsConfig::FontsConfigCommand::rendering_config
        expect(rendering_config).to be_a(String)
        expect(rendering_config.length > 0).to be true
      end
    end
  end

  describe "#metric_compatibility_config" do
    it "returns non-empty string" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        metric_config = FontsConfig::FontsConfigCommand::metric_compatibility_config
        expect(metric_config).to be_a(String)
        expect(metric_config.length > 0).to be true
      end
    end
  end

  describe "#metric_compatibility_symlink" do
    it "returns non-empty string" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        metric_symlink = FontsConfig::FontsConfigCommand::metric_compatibility_symlink
        expect(metric_symlink).to be_a(String)
        expect(metric_symlink.length > 0).to be true
      end
    end
  end

  describe "#metric_compatibility_bw_symlink" do
    it "returns non-empty string" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        metric_bw_symlink = FontsConfig::FontsConfigCommand::metric_compatibility_bw_symlink
        expect(metric_bw_symlink).to be_a(String)
        expect(metric_bw_symlink.length > 0).to be true
      end
    end
  end

  describe "#sysconfig_file" do
    it "returns non-empty string" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        sysconfig_file = FontsConfig::FontsConfigCommand::sysconfig_file
        expect(sysconfig_file).to be_a(String)
        expect(sysconfig_file.length > 0).to be true
      end
    end
  end
end

