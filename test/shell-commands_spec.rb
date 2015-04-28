require_relative "spec-helper"
require "fonts/shell-commands"

require "yast/scr"
require "yast/path"

describe FontsConfig::FontsConfigCommand do
  describe "#run_fonts_config" do    
    it "returns false for system mode" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        expect(FontsConfig::FontsConfigCommand::run_fonts_config("")).to be false
      end
    end
    it "returns true for user mode" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        expect(FontsConfig::FontsConfigCommand::run_fonts_config("--user")).to be true
      end
    end
  end

  describe "#local_family_list_file" do
    it "returns existing file" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        local_family_list_file = 
          FontsConfig::FontsConfigCommand::local_family_list_file
        expect(local_family_list_file).to be_a(String)
        expect(File.exist?(local_family_list_file)).to be true
      end
    end
  end

  describe "#rendering_config" do
    it "returns existing file name" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        rendering_config = FontsConfig::FontsConfigCommand::rendering_config
        expect(rendering_config).to be_a(String)
        expect(File.exist?(rendering_config)).to be true
      end
    end
  end

  describe "#metric_compatibility_avail" do
    it "returns existing file name" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        metric_avail = FontsConfig::FontsConfigCommand::metric_compatibility_avail
        expect(metric_avail).to be_a(String)
        expect(File.exist?(metric_avail)).to be true
      end
    end
  end

  describe "#metric_compatibility_symlink" do
    it "returns existing file name" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        metric_symlink = FontsConfig::FontsConfigCommand::metric_compatibility_symlink
        expect(metric_symlink).to be_a(String)
        expect(File.exist?(metric_symlink)).to be true
      end
    end
  end

  describe "#metric_compatibility_bw_symlink" do
    it "returns existing file name" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        metric_bw_symlink = FontsConfig::FontsConfigCommand::metric_compatibility_bw_symlink
        expect(metric_bw_symlink).to be_a(String)
        expect(File.exist?(metric_bw_symlink)).to be true
      end
    end
  end

  describe "#sysconfig_file" do
    it "returns existing file name" do
      if (FontsConfig::FontsConfigCommand::have_fonts_config?)
        sysconfig_file = FontsConfig::FontsConfigCommand::sysconfig_file
        expect(sysconfig_file).to be_a(String)
        expect(File.exist?(sysconfig_file)).to be true
      end
    end
  end
end

