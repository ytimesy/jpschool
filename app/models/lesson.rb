class Lesson < ApplicationRecord
  belongs_to :course
  has_many :phrases, dependent: :restrict_with_exception
  has_many :dialogues, dependent: :restrict_with_exception
  has_many :dialogue_lines, through: :dialogues
  has_many :quizzes, dependent: :restrict_with_exception

  validates :slug, presence: true, uniqueness: true
  validates :title_i18n, :objective_i18n, :estimated_minutes, presence: true
  validates :content_version, numericality: { only_integer: true, greater_than: 0 }
  validates :validation_status, inclusion: { in: %w[draft valid invalid] }
end
