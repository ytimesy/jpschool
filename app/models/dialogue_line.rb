class DialogueLine < ApplicationRecord
  belongs_to :dialogue
  has_many :quizzes, foreign_key: :source_dialogue_line_id, dependent: :restrict_with_exception, inverse_of: :source_dialogue_line

  validates :content_key, :speaker, :japanese_text, :kana_text, presence: true
  validates :content_key, uniqueness: { scope: :dialogue_id }

  delegate :lesson, to: :dialogue
end
