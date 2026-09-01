class ApplicationController < ActionController::Base
  before_action :set_locale

  helper_method :demo_lessons, :demo_user, :admin_area?, :current_locale, :public_page?

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
      lesson(1, 'ask_confirm', 'completed', 7, 95),
      lesson(2, 'danger_stop', 'passed', 8, 88),
      lesson(3, 'late_absent_health', 'in_progress', 7, 60),
      lesson(4, 'greetings', 'not_started', 7, nil),
      lesson(5, 'self_intro', 'not_started', 6, nil),
      lesson(6, 'time_work', 'not_started', 8, nil),
      lesson(7, 'numbers_units', 'not_started', 6, nil),
      lesson(8, 'tools_places', 'not_started', 7, nil),
      lesson(9, 'safety_signs', 'not_started', 8, nil),
      lesson(10, 'report_contact', 'not_started', 8, nil),
      lesson(11, 'commute_daily', 'not_started', 7, nil),
      lesson(12, 'hospital_disaster', 'not_started', 9, nil)
    ]
  end

  def admin_area?
    request.path.start_with?('/admin')
  end

  def public_page?
    request.path.in?(['/login', '/basic-policy', '/terms', '/company'])
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
      '自己紹介' => ['グエンです。', 'ぐえんです。', 'I am Nguyen.', 'Tôi là Nguyen.', '我是阮。', 'ベトナムから来ました。', 'べとなむから きました。', 'I came from Vietnam.', 'Tôi đến từ Việt Nam.', '我来自越南。'],
      '時間と勤務' => ['休憩は何時からですか。', 'きゅうけいは なんじからですか。', 'What time does the break start?', 'Giờ nghỉ bắt đầu từ mấy giờ?', '休息从几点开始？', '今日は残業がありますか。', 'きょうは ざんぎょうが ありますか。', 'Is there overtime today?', 'Hôm nay có làm thêm không?', '今天有加班吗？'],
      '基本の指示' => ['ここに置いてください。', 'ここに おいてください。', 'Please put it here.', 'Xin hãy đặt ở đây.', '请放在这里。', '少し待ってください。', 'すこし まってください。', 'Please wait a moment.', 'Xin hãy đợi một chút.', '请稍等。'],
      '分からない・確認' => ['分かりません。', 'わかりません。', 'I do not understand.', 'Tôi không hiểu.', '我不明白。', 'もう一度お願いします。', 'もういちど おねがいします。', 'Please say it again.', 'Xin hãy nói lại một lần nữa.', '请再说一遍。'],
      '報告・連絡・相談' => ['終わりました。', 'おわりました。', 'I finished.', 'Tôi đã làm xong.', '我完成了。', '問題があります。', 'もんだいが あります。', 'There is a problem.', 'Có vấn đề.', '有问题。'],
      '数字・個数・単位' => ['三つ必要です。', 'みっつ ひつようです。', 'We need three.', 'Cần ba cái.', '需要三个。', '何個ありますか。', 'なんこ ありますか。', 'How many are there?', 'Có bao nhiêu cái?', '有几个？'],
      '道具と場所' => ['工具はどこですか。', 'こうぐは どこですか。', 'Where are the tools?', 'Dụng cụ ở đâu?', '工具在哪里？', '倉庫にあります。', 'そうこに あります。', 'They are in the warehouse.', 'Ở trong kho.', '在仓库里。'],
      '安全装備・標識' => ['ヘルメットをかぶってください。', 'へるめっとを かぶってください。', 'Please wear a helmet.', 'Xin hãy đội mũ bảo hộ.', '请戴安全帽。', '立入禁止です。', 'たちいりきんしです。', 'No entry.', 'Cấm vào.', '禁止进入。'],
      '危険・停止・避難' => ['止まってください。', 'とまってください。', 'Please stop.', 'Xin hãy dừng lại.', '请停下。', '危ないです。', 'あぶないです。', 'It is dangerous.', 'Nguy hiểm.', '很危险。'],
      '遅刻・欠勤・体調' => ['遅れます。', 'おくれます。', 'I will be late.', 'Tôi sẽ đến muộn.', '我会迟到。', '熱があります。', 'ねつが あります。', 'I have a fever.', 'Tôi bị sốt.', '我发烧了。'],
      '通勤・生活連絡' => ['電車が遅れています。', 'でんしゃが おくれています。', 'The train is delayed.', 'Tàu đang bị trễ.', '电车晚点了。', '住所が変わりました。', 'じゅうしょが かわりました。', 'My address has changed.', 'Địa chỉ của tôi đã thay đổi.', '我的地址变了。'],
      '病院・災害・緊急連絡' => ['病院へ行きたいです。', 'びょういんへ いきたいです。', 'I want to go to the hospital.', 'Tôi muốn đi bệnh viện.', '我想去医院。', '助けてください。', 'たすけてください。', 'Please help me.', 'Xin hãy giúp tôi.', '请帮帮我。']
    }

    samples.fetch(title, ['確認してください。', 'かくにんしてください。', 'Please check it.', 'Xin hãy kiểm tra.', '请确认。', 'これでいいですか。', 'これで いいですか。', 'Is this okay?', 'Như vậy có được không?', '这样可以吗？'])
  end
end
