require "test_helper"

class LessonTest < ActiveSupport::TestCase
  test "position sequence errors detect duplicate and missing sort orders" do
    course = Course.create!(slug: "work-sequence", title_i18n: { ja: "仕事", en: "Work", vi: "Cong viec" })
    first = build_lesson(course:, slug: "first", sort_order: 1)
    second = build_lesson(course:, slug: "second", sort_order: 1)
    third = build_lesson(course:, slug: "third", sort_order: 3)

    errors = Lesson.position_sequence_errors([first, second, third])

    assert_includes errors, "duplicate position 1"
    assert_includes errors, "missing position 2"
  end

  private

  def build_lesson(course:, slug:, sort_order:)
    Lesson.new(
      course:,
      slug:,
      sort_order:,
      title_i18n: { ja: slug, en: slug, vi: slug },
      objective_i18n: { ja: slug, en: slug, vi: slug },
      estimated_minutes: 7
    )
  end
end
