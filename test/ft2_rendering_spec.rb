require_relative "spec-helper"
require "yast/ft2_rendering"

describe Ft2Rendering do
  include Ft2Rendering
  describe "#ft2_have_freetype" do
    it "returns true for regular system" do
      expect(ft2_have_freetype).to be true
    end	
  end
  describe "#ft2_have_subpixel_rendering" do
    it "do not raise" do
      expect(ft2_have_subpixel_rendering).to_not raise_error
    end	
  end
end

