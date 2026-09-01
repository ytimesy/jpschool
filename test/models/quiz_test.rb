require "test_helper"

class QuizTest < ActiveSupport::TestCase
  setup do
    @course = Course.create!(slug: "work", title_i18n: { ja: "仕事", en: "Work", vi: "Cong viec" })
    @lesson = Lesson.create!(
      course: @course,
      slug: "ask-confirm",
      title_i18n: { ja: "確認", en: "Confirm", vi: "Xac nhan" },
      objective_i18n: { ja: "確認する", en: "Confirm", vi: "Xac nhan" },
      estimated_minutes: 7
    )
    @other_lesson = Lesson.create!(
      course: @course,
      slug: "safety",
      title_i18n: { ja: "安全", en: "Safety", vi: "An toan" },
      objective_i18n: { ja: "止まる", en: "Stop", vi: "Dung lai" },
      estimated_minutes: 8
    )
    @phrase = Phrase.create!(lesson: @lesson, content_key: "p01", japanese_text: "分かりません。", kana_text: "わかりません。")
    @other_phrase = Phrase.create!(lesson: @other_lesson, content_key: "p01", japanese_text: "止まってください。", kana_text: "とまってください。")
    dialogue = Dialogue.create!(lesson: @lesson, content_key: "d01", title_i18n: { ja: "会話", en: "Dialogue", vi: "Hoi thoai" })
    @line = DialogueLine.create!(dialogue:, content_key: "dl01", speaker: "learner", japanese_text: "もう一度お願いします。", kana_text: "もういちど おねがいします。")
    other_dialogue = Dialogue.create!(lesson: @other_lesson, content_key: "d01", title_i18n: { ja: "安全", en: "Safety", vi: "An toan" })
    @other_line = DialogueLine.create!(dialogue: other_dialogue, content_key: "dl01", speaker: "supervisor", japanese_text: "危ないです。", kana_text: "あぶないです。")
  end

  test "source phrase must belong to the same lesson" do
    quiz = build_quiz(source_phrase: @other_phrase)

    assert_not quiz.valid?
    assert_includes quiz.errors[:source_phrase], "must belong to the same lesson"
  end

  test "source dialogue line must belong to the same lesson" do
    quiz = build_quiz(source_phrase: nil, source_dialogue_line: @other_line)

    assert_not quiz.valid?
    assert_includes quiz.errors[:source_dialogue_line], "must belong to the same lesson"
  end

  test "exactly one source is required" do
    quiz = build_quiz(source_phrase: nil, source_dialogue_line: nil)

    assert_not quiz.valid?
    assert_includes quiz.errors[:base], "must reference exactly one source phrase or dialogue line"
  end

  test "option locale is limited" do
    quiz = build_quiz(option_locale: "en")

    assert_not quiz.valid?
    assert quiz.errors.of_kind?(:option_locale, :inclusion)
  end

  test "reuse reason is required when reuse is allowed" do
    quiz = build_quiz(reuse_allowed: true, reuse_reason: "")

    assert_not quiz.valid?
    assert quiz.errors.of_kind?(:reuse_reason, :blank)
  end

  private

  def build_quiz(attributes = {})
    Quiz.new({
      lesson: @lesson,
      content_key: "q01",
      kind: "meaning",
      option_locale: "learner",
      source_phrase: @phrase,
      question_ja: "意味はどれですか。"
    }.merge(attributes))
  end
end
