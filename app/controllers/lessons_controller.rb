class LessonsController < ApplicationController
  def index
    @lessons = demo_lessons
  end

  def show
    lesson_id = params[:id].to_i
    @lesson = demo_lessons.find { |lesson| lesson[:id] == lesson_id }

    redirect_to lessons_path, alert: I18n.t('lessons.not_found') unless @lesson
  end
end
