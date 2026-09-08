class QuizzesController < ApplicationController
  def show
    @lesson = demo_lesson(params[:lesson_id])
    return redirect_to lessons_path, alert: I18n.t('lessons.not_found') unless @lesson

    @lesson_id = @lesson[:id]
    @questions = quiz_questions
    @answers = normalized_answers
    @current_index = bounded_question_index(params[:question])
    @current_question = @questions[@current_index]
  end

  def results
    @lesson = demo_lesson(params[:lesson_id])
    return redirect_to lessons_path, alert: I18n.t('lessons.not_found') unless @lesson

    @lesson_id = @lesson[:id]
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
    @next_lesson = next_lesson
  end

  private

  def quiz_questions
    @lesson[:quiz_questions]
  end

  def normalized_answers
    answers = params[:answers]
    return {} unless answers.respond_to?(:permit!)

    answers.permit!.to_h
  end

  def bounded_question_index(value)
    index = value.to_i - 1
    return 0 if index.negative?

    [index, @questions.length - 1].min
  end

  def next_lesson
    next_demo_lesson_after(@lesson_id)
  end
end
