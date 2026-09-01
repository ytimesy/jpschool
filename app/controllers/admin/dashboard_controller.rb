module Admin
  class DashboardController < ApplicationController
    def index
      @summary = {
        active_users: 128,
        learners_today: 24,
        not_started: 17,
        published_lessons: 8,
        draft_lessons: 4
      }
    end
  end
end
