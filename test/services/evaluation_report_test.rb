require "test_helper"

class EvaluationReportTest < ActiveSupport::TestCase
  test "summarizes completion quiz scores and self assessments separately" do
    lessons = DemoLessonCatalog.lessons(locale: :ja)
    report = EvaluationReport.new(
      lessons:,
      user: { display_name: "Demo Learner" },
      self_assessments: {
        "1" => { "rating" => 1, "label" => "一人でできる" },
        "3" => { "rating" => 3, "label" => "かなり助けが必要" }
      }
    )

    assert_equal 12, report.total_lessons
    assert_equal 2, report.completed_count
    assert_equal 2, report.passed_count
    assert_equal 2, report.assessed_count
    assert_equal 95, report.highest_score
    assert_equal 81, report.average_score
    assert_equal 17, report.completion_rate
    assert_equal 17, report.pass_rate
    assert_equal 17, report.self_assessment_rate
  end
end
