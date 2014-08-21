require_relative "spec-helper"
require "fonts/rich-text-dialog"

describe FontsConfig::RichTextDialog do

  def mock_dialog
    ui = double("Yast::UI")
    stub_const("Yast::UI", ui)

    expect(ui).to receive(:CloseDialog).
      and_return(true)

    expect(ui).to receive(:OpenDialog).
      and_return(true)

    expect(ui).to receive(:UserInput).
      and_return("btn_ok")
  end

  it "run rich text dialog with given content" do
    rtd = FontsConfig::RichTextDialog.new
    mock_dialog
    expect(rtd.run("<h1>It works!</h1>", "Test")).to be_true
  end
end
