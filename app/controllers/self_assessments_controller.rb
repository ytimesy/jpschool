class SelfAssessmentsController < ApplicationController
  def update
    lesson = demo_lesson(params[:lesson_id])
    return redirect_to lessons_path, alert: I18n.t("lessons.not_found") unless lesson

    rating = params[:rating].to_i
    unless (1..4).cover?(rating)
      return redirect_to lesson_path(lesson[:id]), alert: I18n.t("lesson_detail.self_assessment_invalid")
    end

    option = lesson[:self_assessment_options].find { |candidate| candidate[:rating] == rating }
    self_assessment_store[lesson[:id].to_s] = {
      "rating" => rating,
      "can_do_code" => lesson[:can_do][:code],
      "label" => option[:label],
      "assessed_at" => Time.current.iso8601
    }

    redirect_to lesson_path(lesson[:id]), notice: I18n.t("lesson_detail.self_assessment_saved")
  end
end
