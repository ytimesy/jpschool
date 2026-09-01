class QuizOption < ApplicationRecord
  belongs_to :quiz

  validates :content_key, :text_ja, presence: true
  validates :content_key, uniqueness: { scope: :quiz_id }
end
