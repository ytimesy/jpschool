class QuizzesController < ApplicationController
  def show
    # sample quiz for lesson
    @lesson_id = params[:lesson_id]
    @questions = [
      { id: 1, question: I18n.t('quiz.question_1'), options: I18n.t('quiz.options_1'), answer: 2 },
      { id: 2, question: I18n.t('quiz.question_2'), options: I18n.t('quiz.options_2'), answer: 1 }
    ]
  end

  def results
    # simple scoring logic from params
    correct = 0
    answers = params[:answers] || {}
    answer_key = { 1 => 2, 2 => 1 }
    answers.each do |question_id, selected_option|
      correct += 1 if selected_option.to_i == answer_key[question_id.to_i]
    end
    @score = (correct.to_f / 2 * 100).to_i
    @correct = correct
    @total = 2
  end
end
