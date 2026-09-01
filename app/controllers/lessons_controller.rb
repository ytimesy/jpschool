class LessonsController < ApplicationController
  def index
    @lessons = [
      { id: 1, title: '挨拶と自己紹介', description: '職場で使う基本の挨拶と自己紹介' },
      { id: 2, title: '会議での発言', description: '簡潔に意見を述べる表現' },
      { id: 3, title: 'メールの書き方', description: '業務用の簡潔なメール表現' }
    ]
  end
end
