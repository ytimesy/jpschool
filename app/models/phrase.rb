class Phrase < ApplicationRecord
  belongs_to :lesson
  has_many :quizzes, foreign_key: :source_phrase_id, dependent: :restrict_with_exception, inverse_of: :source_phrase

  validates :content_key, :japanese_text, :kana_text, presence: true
  validates :content_key, uniqueness: { scope: :lesson_id }
end
