module Admin
  class LessonsController < ApplicationController
    def index
      @lessons = demo_lessons.map.with_index do |lesson, index|
        lesson.merge(
          version: "2026.09.#{index + 1}",
          translation_status: index < 8 ? '完了' : '不足あり',
          audio_status: index < 6 ? '完了' : '警告',
          published: index < 8
        )
      end
    end

    def show
      @lesson = demo_lessons.find { |lesson| lesson[:id] == params[:id].to_i } || demo_lessons.first
    end

    def preview
      @lesson = demo_lessons.find { |lesson| lesson[:id] == params[:id].to_i } || demo_lessons.first
    end
  end
end
