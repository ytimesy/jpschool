class LessonsController < ApplicationController
  def index
    @lessons = [
      { id: 1, title: '挨拶と自己紹介', description: '職場で使う基本の挨拶と自己紹介' },
      { id: 2, title: '会議での発言', description: '簡潔に意見を述べる表現' },
      { id: 3, title: 'メールの書き方', description: '業務用の簡潔なメール表現' }
    ]
  end

  def show
    lesson_id = params[:id].to_i
    # sample lesson content (in a real app this comes from DB)
    @lesson = {
      id: lesson_id,
      title: @lessons&.find { |l| l[:id] == lesson_id }&.dig(:title) || "レッスン "+lesson_id.to_s,
      objective: '職場で使う基本表現を学ぶ',
      phrases: [
        { id: 1, japanese: 'おはようございます', kana: 'おはようございます', translation: { ja: 'おはようございます', en: 'Good morning' }, audio: nil },
        { id: 2, japanese: 'よろしくお願いします', kana: 'よろしくおねがいします', translation: { ja: 'よろしくお願いします', en: 'Nice to meet you' }, audio: nil }
      ]
    }
  end
end
