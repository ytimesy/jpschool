require "test_helper"

class ProgressControllerTest < ActionDispatch::IntegrationTest
  test "progress lists all public lessons in position order" do
    get progress_url

    assert_response :success
    assert_select "tbody tr", count: 12
    assert_ordered_texts("分からない・確認", "危険・停止・避難", "遅刻・欠勤・体調", "あいさつ")
  end

  private

  def assert_ordered_texts(*texts)
    positions = texts.map { |text| response.body.index(text) }
    assert positions.all?, "Expected all texts to be present: #{texts.inspect}"
    assert_equal positions.sort, positions
  end
end
