class Quiz < ApplicationRecord
  belongs_to :lesson
  belongs_to :source_phrase, class_name: "Phrase", optional: true
  belongs_to :source_dialogue_line, class_name: "DialogueLine", optional: true
  has_many :quiz_options, dependent: :restrict_with_exception

  validates :content_key, :kind, :option_locale, :question_ja, presence: true
  validates :content_key, uniqueness: { scope: :lesson_id }
  validates :option_locale, inclusion: { in: %w[learner ja] }
  validates :reuse_reason, presence: true, if: :reuse_allowed?
  validate :exactly_one_source
  validate :source_belongs_to_lesson

  private

  def exactly_one_source
    return if source_phrase.present? ^ source_dialogue_line.present?

    errors.add(:base, "must reference exactly one source phrase or dialogue line")
  end

  def source_belongs_to_lesson
    if source_phrase.present? && source_phrase.lesson_id != lesson_id
      errors.add(:source_phrase, "must belong to the same lesson")
    end

    if source_dialogue_line.present? && source_dialogue_line.lesson.id != lesson_id
      errors.add(:source_dialogue_line, "must belong to the same lesson")
    end
  end
end
