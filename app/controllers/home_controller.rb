class HomeController < ApplicationController
  def index
    @next_lesson = next_demo_lesson_for_home
  end
end
