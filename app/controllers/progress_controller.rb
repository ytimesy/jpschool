class ProgressController < ApplicationController
  def index
    @summary = { completed: 3, review_count: 2, highest_score: 95 }
    @lessons = demo_lessons
  end
end
