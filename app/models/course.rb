class Course < ApplicationRecord
  has_many :lessons, dependent: :restrict_with_exception

  validates :slug, presence: true, uniqueness: true
  validates :title_i18n, presence: true
end
