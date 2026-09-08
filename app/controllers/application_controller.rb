class ApplicationController < ActionController::Base
  before_action :set_locale

  helper_method :demo_lessons, :demo_user, :admin_area?, :current_locale, :public_page?, :self_assessment_for

  def demo_user
    {
      display_name: 'Nguyen Van A',
      locale: current_locale.to_s,
      department: '工場1',
      job_type: '製造',
      completed_count: 3,
      passed_count: 2,
      review_count: 4
    }
  end

  def demo_lessons
    DemoLessonCatalog.lessons(locale: current_locale)
  end

  def demo_lesson(id)
    DemoLessonCatalog.find(id, locale: current_locale)
  end

  def next_demo_lesson_after(id)
    DemoLessonCatalog.next_after(id, locale: current_locale)
  end

  def next_demo_lesson_for_home
    DemoLessonCatalog.next_for_home(locale: current_locale)
  end

  def self_assessment_for(lesson_id)
    self_assessment_store[lesson_id.to_s]
  end

  def admin_area?
    request.path.start_with?('/admin')
  end

  def public_page?
    request.path.in?(['/login', '/basic-policy', '/terms', '/company'])
  end

  def current_locale
    I18n.locale
  end

  private

  def set_locale
    locale = params[:locale].presence || session[:locale].presence || I18n.default_locale
    locale = I18n.default_locale unless I18n.available_locales.map(&:to_s).include?(locale.to_s)

    I18n.locale = locale
    session[:locale] = locale
  end

  def self_assessment_store
    session[:self_assessments] ||= {}
  end

end
