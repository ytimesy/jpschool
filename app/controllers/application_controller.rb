class ApplicationController < ActionController::Base
  before_action :set_locale

  helper_method :demo_lessons, :demo_user, :admin_area?, :current_locale

  def demo_user
    {
      display_name: 'Nguyen Van A',
      locale: current_locale.to_s,
      department: '工場1',
      job_type: '製造',
      completed_count: 3,
      passed_count: 2,
      review_count: 4
    }
  end

  def demo_lessons
    [
      lesson(1, 'greetings', 'completed', 7, 95),
      lesson(2, 'self_intro', 'passed', 6, 88),
      lesson(3, 'time_work', 'in_progress', 8, 60),
      lesson(4, 'instructions', 'not_started', 7, nil),
      lesson(5, 'ask_confirm', 'not_started', 7, nil),
      lesson(6, 'report_contact', 'not_started', 8, nil),
      lesson(7, 'numbers_units', 'not_started', 6, nil),
      lesson(8, 'tools_places', 'not_started', 7, nil),
      lesson(9, 'safety_signs', 'not_started', 8, nil),
      lesson(10, 'danger_stop', 'not_started', 8, nil),
      lesson(11, 'late_absent_health', 'not_started', 7, nil),
      lesson(12, 'hospital_disaster', 'not_started', 9, nil)
    ]
  end

  def admin_area?
    request.path.start_with?('/admin')
  end

  def current_locale
    I18n.locale
  end

  private

  def set_locale
    locale = params[:locale].presence || session[:locale].presence || I18n.default_locale
    locale = I18n.default_locale unless I18n.available_locales.map(&:to_s).include?(locale.to_s)

    I18n.locale = locale
    session[:locale] = locale
  end

  def lesson(id, key, status_key, minutes, highest_score)
    japanese_title = I18n.t("lessons.#{key}.title", locale: :ja)

    {
      id: id,
      key: key,
      japanese_title: japanese_title,
      title: I18n.t("lessons.#{key}.title"),
      description: I18n.t("lessons.#{key}.description"),
      objective: I18n.t("lessons.#{key}.objective"),
      status: I18n.t("statuses.#{status_key}"),
      minutes: minutes,
      highest_score: highest_score,
      phrases: [
        {
          id: 1,
          japanese: sample_phrase_for(japanese_title).first,
          kana: sample_phrase_for(japanese_title)[1],
          translation: { ja: sample_phrase_for(japanese_title).first, en: sample_phrase_for(japanese_title)[2], vi: sample_phrase_for(japanese_title)[3], zh: sample_phrase_for(japanese_title)[4] },
          note: I18n.t('lesson_detail.note_primary'),
          audio: nil
        },
        {
          id: 2,
          japanese: sample_phrase_for(japanese_title)[5],
          kana: sample_phrase_for(japanese_title)[6],
          translation: { ja: sample_phrase_for(japanese_title)[5], en: sample_phrase_for(japanese_title)[7], vi: sample_phrase_for(japanese_title)[8], zh: sample_phrase_for(japanese_title)[9] },
          note: I18n.t('lesson_detail.note_secondary'),
          audio: nil
        }
      ]
    }
  end

  def sample_phrase_for(title)
    samples = {
      'あいさつ' => ['おはようございます。', 'おはようございます。', 'Good morning.', 'Chào buổi sáng.', '早上好。', 'よろしくお願いします。', 'よろしく おねがいします。', 'I look forward to working with you.', 'Rất mong được giúp đỡ.', '请多关照。'],
      '分からない・確認' => ['分かりません。', 'わかりません。', 'I do not understand.', 'Tôi không hiểu.', '我不明白。', 'もう一度お願いします。', 'もういちど おねがいします。', 'Please say it again.', 'Xin hãy nói lại một lần nữa.', '请再说一遍。'],
      '危険・停止・避難' => ['止まってください。', 'とまってください。', 'Please stop.', 'Xin hãy dừng lại.', '请停下。', '危ないです。', 'あぶないです。', 'It is dangerous.', 'Nguy hiểm.', '很危险。']
    }

    samples.fetch(title, ['確認してください。', 'かくにんしてください。', 'Please check it.', 'Xin hãy kiểm tra.', '请确认。', 'これでいいですか。', 'これで いいですか。', 'Is this okay?', 'Như vậy có được không?', '这样可以吗？'])
  end
end
