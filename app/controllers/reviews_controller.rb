class ReviewsController < ApplicationController
  def index
    @items = [
      { id: 1, question: I18n.t('quiz.question_1'), wrong_count: 2, options: I18n.t('quiz.options_1') },
      { id: 2, question: I18n.t('quiz.question_2'), wrong_count: 1, options: I18n.t('quiz.options_2') }
    ]
  end
end
