class QuizzesController < ApplicationController
  def show
    @lesson_id = params[:lesson_id]
    @questions = quiz_questions
    @answers = normalized_answers
    @current_index = bounded_question_index(params[:question])
    @current_question = @questions[@current_index]
  end

  def results
    @lesson_id = params[:lesson_id]
    @questions = quiz_questions
    @answers = normalized_answers
    @current_index = bounded_question_index(params[:question])

    if @current_index < @questions.length - 1
      @current_index += 1
      @current_question = @questions[@current_index]
      return render :show, status: :ok
    end

    correct = 0
    @questions.each do |question|
      correct += 1 if @answers[question[:id].to_s].to_i == question[:answer]
    end
    @score = (correct.to_f / @questions.length * 100).to_i
    @correct = correct
    @total = @questions.length
  end

  private

  def quiz_questions
    [
      {
        id: 1,
        kana: I18n.t('quiz.question_1_kana'),
        question: I18n.t('quiz.question_1'),
        option_locale: 'learner',
        options: I18n.t('quiz.options_1'),
        answer: 2
      },
      {
        id: 2,
        kana: I18n.t('quiz.question_2_kana'),
        question: I18n.t('quiz.question_2'),
        option_locale: 'learner',
        options: I18n.t('quiz.options_2'),
        answer: 1
      }
    ]
  end

  def normalized_answers
    answers = params[:answers]
    return {} unless answers.respond_to?(:permit!)

    answers.permit!.to_h
  end

  def bounded_question_index(value)
    index = value.to_i - 1
    return 0 if index.negative?

    [index, quiz_questions.length - 1].min
  end
end
