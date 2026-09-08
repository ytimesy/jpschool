class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :authenticate_user!
  before_action :require_admin!, if: :admin_area?
  before_action :no_store_for_protected_pages

  helper_method :current_user, :demo_lessons, :demo_user, :admin_area?, :current_locale, :public_page?, :self_assessment_for

  def demo_user
    return guest_demo_user unless current_user

    {
      display_name: current_user.display_name,
      locale: current_user.locale,
      department: current_user.department,
      job_type: current_user.job_type,
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
    return unless current_user

    self_assessment_store[lesson_id.to_s]
  end

  def admin_area?
    request.path.start_with?('/admin')
  end

  def public_page?
    request.path.in?(['/login', '/auth/failure', '/initial-setup', '/basic-policy', '/terms', '/company']) ||
      request.path.match?(%r{\A/auth/[^/]+/callback\z})
  end

  def current_locale
    I18n.locale
  end

  def current_user
    @current_user ||= AuthenticatedUser.from_session(session[:authenticated_user])
  end

  private

  def set_locale
    locale = params[:locale].presence || session[:locale].presence || I18n.default_locale
    locale = I18n.default_locale unless I18n.available_locales.map(&:to_s).include?(locale.to_s)

    I18n.locale = locale
    session[:locale] = locale
  end

  def authenticate_user!
    return if public_page?
    return if current_user&.active?

    reset_session if current_user&.stopped?
    redirect_to login_path, alert: I18n.t("login.required")
  end

  def require_admin!
    return if public_page?
    return if current_user&.admin?

    redirect_to root_path, alert: I18n.t("login.admin_required")
  end

  def no_store_for_protected_pages
    return if public_page?

    response.headers["Cache-Control"] = "no-store, private"
  end

  def guest_demo_user
    {
      display_name: "Demo Learner",
      locale: current_locale.to_s,
      department: "",
      job_type: "",
      completed_count: 0,
      passed_count: 0,
      review_count: 0
    }
  end

  def self_assessment_store
    session[:self_assessments] ||= {}
  end
end
