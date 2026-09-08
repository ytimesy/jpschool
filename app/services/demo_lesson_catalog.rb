class DemoLessonCatalog
  LessonData = Struct.new(:id, :key, :status_key, :minutes, :highest_score, keyword_init: true)

  LESSONS = [
    LessonData.new(id: 1, key: "ask_confirm", status_key: "completed", minutes: 7, highest_score: 95),
    LessonData.new(id: 2, key: "danger_stop", status_key: "passed", minutes: 8, highest_score: 88),
    LessonData.new(id: 3, key: "late_absent_health", status_key: "in_progress", minutes: 7, highest_score: 60),
    LessonData.new(id: 4, key: "greetings", status_key: "not_started", minutes: 7, highest_score: nil),
    LessonData.new(id: 5, key: "self_intro", status_key: "not_started", minutes: 6, highest_score: nil),
    LessonData.new(id: 6, key: "time_work", status_key: "not_started", minutes: 8, highest_score: nil),
    LessonData.new(id: 7, key: "numbers_units", status_key: "not_started", minutes: 6, highest_score: nil),
    LessonData.new(id: 8, key: "tools_places", status_key: "not_started", minutes: 7, highest_score: nil),
    LessonData.new(id: 9, key: "safety_signs", status_key: "not_started", minutes: 8, highest_score: nil),
    LessonData.new(id: 10, key: "report_contact", status_key: "not_started", minutes: 8, highest_score: nil),
    LessonData.new(id: 11, key: "commute_daily", status_key: "not_started", minutes: 7, highest_score: nil),
    LessonData.new(id: 12, key: "hospital_disaster", status_key: "not_started", minutes: 9, highest_score: nil)
  ].freeze

  SAMPLES = {
    "あいさつ" => ["おはようございます。", "おはようございます。", "Good morning.", "Chào buổi sáng.", "早上好。", "よろしくお願いします。", "よろしく おねがいします。", "I look forward to working with you.", "Rất mong được giúp đỡ.", "请多关照。"],
    "自己紹介" => ["グエンです。", "ぐえんです。", "I am Nguyen.", "Tôi là Nguyen.", "我是阮。", "ベトナムから来ました。", "べとなむから きました。", "I came from Vietnam.", "Tôi đến từ Việt Nam.", "我来自越南。"],
    "時間と勤務" => ["休憩は何時からですか。", "きゅうけいは なんじからですか。", "What time does the break start?", "Giờ nghỉ bắt đầu từ mấy giờ?", "休息从几点开始？", "今日は残業がありますか。", "きょうは ざんぎょうが ありますか。", "Is there overtime today?", "Hôm nay có làm thêm không?", "今天有加班吗？"],
    "分からない・確認" => ["分かりません。", "わかりません。", "I do not understand.", "Tôi không hiểu.", "我不明白。", "もう一度お願いします。", "もういちど おねがいします。", "Please say it again.", "Xin hãy nói lại một lần nữa.", "请再说一遍。"],
    "報告・連絡・相談" => ["終わりました。", "おわりました。", "I finished.", "Tôi đã làm xong.", "我完成了。", "問題があります。", "もんだいが あります。", "There is a problem.", "Có vấn đề.", "有问题。"],
    "数字・個数・単位" => ["三つ必要です。", "みっつ ひつようです。", "We need three.", "Cần ba cái.", "需要三个。", "何個ありますか。", "なんこ ありますか。", "How many are there?", "Có bao nhiêu cái?", "有几个？"],
    "道具と場所" => ["工具はどこですか。", "こうぐは どこですか。", "Where are the tools?", "Dụng cụ ở đâu?", "工具在哪里？", "倉庫にあります。", "そうこに あります。", "They are in the warehouse.", "Ở trong kho.", "在仓库里。"],
    "安全装備・標識" => ["ヘルメットをかぶってください。", "へるめっとを かぶってください。", "Please wear a helmet.", "Xin hãy đội mũ bảo hộ.", "请戴安全帽。", "立入禁止です。", "たちいりきんしです。", "No entry.", "Cấm vào.", "禁止进入。"],
    "危険・停止・避難" => ["止まってください。", "とまってください。", "Please stop.", "Xin hãy dừng lại.", "请停下。", "危ないです。", "あぶないです。", "It is dangerous.", "Nguy hiểm.", "很危险。"],
    "遅刻・欠勤・体調" => ["遅れます。", "おくれます。", "I will be late.", "Tôi sẽ đến muộn.", "我会迟到。", "熱があります。", "ねつが あります。", "I have a fever.", "Tôi bị sốt.", "我发烧了。"],
    "通勤・生活連絡" => ["電車が遅れています。", "でんしゃが おくれています。", "The train is delayed.", "Tàu đang bị trễ.", "电车晚点了。", "住所が変わりました。", "じゅうしょが かわりました。", "My address has changed.", "Địa chỉ của tôi đã thay đổi.", "我的地址变了。"],
    "病院・災害・緊急連絡" => ["病院へ行きたいです。", "びょういんへ いきたいです。", "I want to go to the hospital.", "Tôi muốn đi bệnh viện.", "我想去医院。", "助けてください。", "たすけてください。", "Please help me.", "Xin hãy giúp tôi.", "请帮帮我。"]
  }.freeze

  DISTRACTORS = {
    ja: "終わりました。",
    en: "I finished.",
    vi: "Tôi đã xong.",
    zh: "我完成了。"
  }.freeze

  class << self
    def lessons(locale: I18n.locale)
      LESSONS.map { |data| build_lesson(data, locale:) }.sort_by { |lesson| lesson[:position] }
    end

    def find(id, locale: I18n.locale)
      lessons(locale:).find { |lesson| lesson[:id] == id.to_i }
    end

    def next_after(id, locale: I18n.locale)
      current = find(id, locale:)
      return unless current

      lessons(locale:).find { |lesson| lesson[:position] > current[:position] }
    end

    def next_for_home(locale: I18n.locale)
      lessons(locale:).find { |lesson| lesson[:status_key] == "in_progress" } ||
        lessons(locale:).find { |lesson| lesson[:status_key] == "not_started" } ||
        lessons(locale:).first
    end

    private

    def build_lesson(data, locale:)
      japanese_title = I18n.t("lessons.#{data.key}.title", locale: :ja)
      samples = SAMPLES.fetch(japanese_title)
      phrases = build_phrases(samples)

      {
        id: data.id,
        position: data.id,
        key: data.key,
        status_key: data.status_key,
        published: true,
        japanese_title:,
        title: I18n.t("lessons.#{data.key}.title", locale:),
        description: I18n.t("lessons.#{data.key}.description", locale:),
        objective: I18n.t("lessons.#{data.key}.objective", locale:),
        status: I18n.t("statuses.#{data.status_key}", locale:),
        minutes: data.minutes,
        highest_score: data.highest_score,
        phrases:,
        dialogue_lines: build_dialogue_lines(samples, locale),
        quiz_questions: build_quiz_questions(samples, locale)
      }
    end

    def build_phrases(samples)
      [
        phrase(1, samples[0], samples[1], samples[2], samples[3], samples[4], "lesson_detail.note_primary"),
        phrase(2, samples[5], samples[6], samples[7], samples[8], samples[9], "lesson_detail.note_secondary")
      ]
    end

    def phrase(id, japanese, kana, en, vi, zh, note_key)
      {
        id:,
        japanese:,
        kana:,
        translation: { ja: japanese, en:, vi:, zh: },
        note: I18n.t(note_key),
        audio: nil
      }
    end

    def build_dialogue_lines(samples, locale)
      [
        {
          speaker: I18n.t("lessons.senior", locale:),
          japanese: samples[0],
          kana: samples[1],
          translation: translated(samples, 0, locale)
        },
        {
          speaker: I18n.t("lessons.learner", locale:),
          japanese: samples[5],
          kana: samples[6],
          translation: translated(samples, 5, locale)
        }
      ]
    end

    def build_quiz_questions(samples, locale)
      [
        quiz_question(1, samples, 0, 5, locale),
        quiz_question(2, samples, 5, 0, locale)
      ]
    end

    def quiz_question(id, samples, source_index, other_index, locale)
      effective_locale = locale.to_sym

      {
        id:,
        kana: "「#{samples[source_index + 1]}」の いみは どれですか。",
        question: "「#{samples[source_index]}」の意味はどれですか。",
        option_locale: "learner",
        options: [
          translated(samples, source_index, effective_locale),
          translated(samples, other_index, effective_locale),
          DISTRACTORS.fetch(effective_locale, DISTRACTORS[:en])
        ],
        answer: 1
      }
    end

    def translated(samples, start_index, locale)
      case locale.to_sym
      when :ja
        samples[start_index]
      when :vi
        samples[start_index + 3]
      when :zh
        samples[start_index + 4]
      else
        samples[start_index + 2]
      end
    end
  end
end
