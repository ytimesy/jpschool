class Dialogue < ApplicationRecord
  belongs_to :lesson
  has_many :dialogue_lines, dependent: :restrict_with_exception

  validates :content_key, presence: true, uniqueness: { scope: :lesson_id }
  validates :title_i18n, presence: true
end
