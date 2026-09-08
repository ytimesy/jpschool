require "test_helper"

class LessonsControllerTest < ActionDispatch::IntegrationTest
  test "lesson index lists all public lessons in position order" do
    get lessons_url

    assert_response :success
    assert_select ".lesson-card", count: 12
    assert_select ".can-do-summary", minimum: 12
    assert_ordered_texts("分からない・確認", "危険・停止・避難", "遅刻・欠勤・体調", "あいさつ")
  end

  test "lesson detail shows Can do task flow and self assessment" do
    get lesson_url(2)

    assert_response :success
    assert_match "今日のCan do", response.body
    assert_match "話すこと・やり取り", response.body
    assert_match "まず挑戦する", response.body
    assert_match "部分練習", response.body
    assert_match "課題遂行・ロールプレイ", response.body
    assert_match "Can do自己評価", response.body
    assert_select ".self-assessment-options input[type=radio]", count: 4
  end

  test "lesson detail uses dialogue lines from the selected lesson" do
    get lesson_url(2)

    assert_response :success
    assert_match "止まってください。", response.body
    assert_match "危ないです。", response.body
    assert_no_match "この箱を入口へ持ってきてください。", response.body
  end

  test "lesson detail uses Japanese audio files for phrases" do
    get lesson_url(1)

    assert_response :success
    assert_select ".audio-box", count: 2
    assert_select "audio[src='/audio/demo/lesson-01-phrase-01.m4a']"
    assert_select "audio[src='/audio/demo/lesson-01-phrase-02.m4a']"
    assert_select ".speed-control", count: 2
    assert_select "button[data-audio-speed='0.75']"
    assert_select "button[data-audio-speed='1.0']"
    assert_match "0.75x", response.body
    assert_match "1.0x", response.body
  end

  private

  def assert_ordered_texts(*texts)
    positions = texts.map { |text| response.body.index(text) }
    assert positions.all?, "Expected all texts to be present: #{texts.inspect}"
    assert_equal positions.sort, positions
  end
end
