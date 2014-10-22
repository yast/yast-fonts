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
    it "returns true or false" do
      expect(ft2_have_subpixel_rendering == true ||
             ft2_have_subpixel_rendering == false).to be true
    end	
  end
end

