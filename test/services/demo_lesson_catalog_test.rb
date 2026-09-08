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

    assert_equal 4, ask_confirm[:quiz_questions].length
    assert_equal 4, danger_stop[:quiz_questions].length
    assert_match "分かりません", ask_confirm[:quiz_questions].first[:question]
    assert_match "止まってください", danger_stop[:quiz_questions].first[:question]
    assert_no_match "おはようございます", danger_stop[:quiz_questions].first[:question]
  end

  test "quiz question volume uses learner and Japanese choice checks" do
    lesson = DemoLessonCatalog.find(10, locale: :en)

    assert_equal [1, 2, 3, 4], lesson[:quiz_questions].map { |question| question[:id] }
    assert_equal %w[learner learner ja ja], lesson[:quiz_questions].map { |question| question[:option_locale] }
    assert lesson[:quiz_questions].all? { |question| question[:options].length == 3 }
    assert lesson[:quiz_questions].all? { |question| question[:options].uniq == question[:options] }
  end

  test "phrases point to generated Japanese audio files" do
    lesson = DemoLessonCatalog.find(12, locale: :ja)

    assert_equal "/audio/demo/lesson-12-phrase-01.m4a", lesson[:phrases].first[:audio]
    assert_equal "/audio/demo/lesson-12-phrase-02.m4a", lesson[:phrases].second[:audio]
  end

  test "lessons include Can do metadata and task flow" do
    lesson = DemoLessonCatalog.find(4, locale: :en)

    assert_equal "WN-A1-04", lesson[:can_do][:code]
    assert_equal "A1", lesson[:can_do][:level]
    assert_equal "spoken_interaction", lesson[:can_do][:activity_code]
    assert_includes lesson[:pre_task], "おはようございます"
    assert_equal 2, lesson[:practice].length
    assert_equal 4, lesson[:role_play][:checklist].length
    assert_equal 4, lesson[:self_assessment_options].length
  end
end
