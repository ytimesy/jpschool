class LessonsController < ApplicationController
  def index
    @lessons = demo_lessons
  end

  def show
    @lesson = demo_lesson(params[:id])

    redirect_to lessons_path, alert: I18n.t('lessons.not_found') unless @lesson
  end
end
