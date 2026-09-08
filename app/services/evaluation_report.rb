class EvaluationReport
  PASS_SCORE = 80

  attr_reader :lessons, :user, :self_assessments, :issued_on

  def initialize(lessons:, user:, self_assessments:, issued_on: Time.zone.today)
    @lessons = lessons
    @user = user
    @self_assessments = self_assessments.to_h.transform_keys(&:to_s)
    @issued_on = issued_on
  end

  def total_lessons
    lessons.length
  end

  def completed_count
    lesson_rows.count { |row| row[:completed] }
  end

  def passed_count
    lesson_rows.count { |row| row[:passed] }
  end

  def assessed_count
    lesson_rows.count { |row| row[:self_assessment].present? }
  end

  def highest_score
    scored_lessons.map { |lesson| lesson[:highest_score] }.max
  end

  def average_score
    return unless scored_lessons.any?

    (scored_lessons.sum { |lesson| lesson[:highest_score] }.to_f / scored_lessons.length).round
  end

  def completion_rate
    percentage(completed_count)
  end

  def pass_rate
    percentage(passed_count)
  end

  def self_assessment_rate
    percentage(assessed_count)
  end

  def lesson_rows
    @lesson_rows ||= lessons.map do |lesson|
      score = lesson[:highest_score]
      assessment = self_assessments[lesson[:id].to_s]

      {
        id: lesson[:id],
        position: lesson[:position],
        title: lesson[:title],
        can_do: lesson[:can_do][:statement],
        activity: lesson[:can_do][:activity_label],
        status: lesson[:status],
        completed: %w[completed passed].include?(lesson[:status_key]),
        highest_score: score,
        passed: score.present? && score >= PASS_SCORE,
        self_assessment: assessment_label(assessment)
      }
    end
  end

  private

  def assessment_label(assessment)
    return if assessment.blank?
    return assessment.label if assessment.respond_to?(:label)

    assessment.fetch("label", nil)
  end

  def scored_lessons
    lessons.select { |lesson| lesson[:highest_score].present? }
  end

  def percentage(count)
    return 0 if total_lessons.zero?

    (count.to_f / total_lessons * 100).round
  end
end
