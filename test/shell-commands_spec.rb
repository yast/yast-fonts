require_relative "spec-helper"
require "fonts/shell-commands"

describe FontsConfig::FontsConfigCommand do
  describe "#run_fonts_config" do    
    it "error popup when not run under root" do
      if (Process.uid != 0)
        expect(FontsConfig::FontsConfigCommand::run_fonts_config).to be false
      end
    end

    it "no error popup when run under root" do
      if (Process.uid == 0)
        expect(FontsConfig::FontsConfigCommand::run_fonts_config).to be true
      end
    end
  end
end

