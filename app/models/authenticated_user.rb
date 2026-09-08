class AuthenticatedUser
  attr_reader :email, :display_name, :locale, :picture_url

  def self.from_session(attributes)
    return if attributes.blank?

    new(attributes)
  end

  def initialize(attributes)
    @email = attributes.fetch("email")
    @display_name = attributes["display_name"].presence || email
    @locale = attributes["locale"].presence || I18n.default_locale.to_s
    @picture_url = attributes["picture_url"].to_s
  end

  def admin?
    email.in?(email_list("GOOGLE_ADMIN_EMAILS"))
  end

  def active?
    !stopped?
  end

  def stopped?
    email.in?(email_list("GOOGLE_STOPPED_EMAILS"))
  end

  def department
    ""
  end

  def job_type
    ""
  end

  private

  def email_list(key)
    ENV.fetch(key, "").split(",").map { |value| value.strip.downcase }.reject(&:blank?)
  end
end
