class QuizzesController < ApplicationController
  def show
    # sample quiz for lesson
    @lesson_id = params[:lesson_id]
    @questions = [
      { id: 1, question: '「おはようございます」の意味は？', options: ['Good night','Good morning','Thank you'], answer: 2 },
      { id: 2, question: '「よろしくお願いします」の意味は？', options: ['Nice to meet you','See you','Sorry'], answer: 1 }
    ]
  end

  def results
    # simple scoring logic from params
    correct = 0
    answers = params[:answers] || {}
    answers.each do |k,v|
      correct += 1 if v.to_i ==  (k.to_i == 1 ? 2 : 1) # align with sample answers above
    end
    @score = (correct.to_f / 2 * 100).to_i
    @correct = correct
    @total = 2
  end
end
