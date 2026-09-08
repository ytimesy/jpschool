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

  scope :position_order, -> { order(:sort_order, :id) }

  def position
    sort_order
  end

  def self.position_sequence_errors(records = all)
    positions = records.map(&:position)
    errors = []

    positions.tally.each do |position, count|
      errors << "duplicate position #{position}" if count > 1
    end

    expected_positions = (1..positions.length).to_a
    (expected_positions - positions).each do |position|
      errors << "missing position #{position}"
    end

    errors
  end
end
