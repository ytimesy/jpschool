require "test_helper"

class DemoLessonCatalogTest < ActiveSupport::TestCase
  test "lessons are returned in position order" do
    lessons = DemoLessonCatalog.lessons(locale: :ja)

    assert_equal 12, lessons.length
    assert_equal (1..12).to_a, lessons.map { |lesson| lesson[:position] }
    assert_equal "分からない・確認", lessons.first[:title]
  end

  test "quiz questions are scoped to each lesson" do
    ask_confirm = DemoLessonCatalog.find(1, locale: :ja)
    danger_stop = DemoLessonCatalog.find(2, locale: :ja)

    assert_match "分かりません", ask_confirm[:quiz_questions].first[:question]
    assert_match "止まってください", danger_stop[:quiz_questions].first[:question]
    assert_no_match "おはようございます", danger_stop[:quiz_questions].first[:question]
  end
end
