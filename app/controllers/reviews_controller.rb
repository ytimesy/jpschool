class ReviewsController < ApplicationController
  def index
    @items = [
      { id: 1, question: '「おはようございます」の意味は？', wrong_count: 2 },
      { id: 2, question: '「よろしくお願いします」の意味は？', wrong_count: 1 }
    ]
  end
end
