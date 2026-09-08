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

  DISTRACTOR_POOLS = {
    ja: ["終わりました。", "休憩します。", "確認します。", "待ってください。"],
    en: ["I finished.", "I will take a break.", "I will check.", "Please wait."],
    vi: ["Tôi đã xong.", "Tôi sẽ nghỉ giải lao.", "Tôi sẽ kiểm tra.", "Xin hãy chờ."],
    zh: ["我完成了。", "我要休息。", "我会确认。", "请等一下。"]
  }.freeze

  ACTIVITY_CODES = {
    "ask_confirm" => "spoken_interaction",
    "danger_stop" => "spoken_interaction",
    "late_absent_health" => "spoken_interaction",
    "greetings" => "spoken_interaction",
    "self_intro" => "spoken_presentation",
    "time_work" => "listening",
    "numbers_units" => "listening",
    "tools_places" => "listening",
    "safety_signs" => "reading",
    "report_contact" => "spoken_presentation",
    "commute_daily" => "writing",
    "hospital_disaster" => "spoken_interaction"
  }.freeze

  FRAMEWORK_REFERENCES = {
    "ask_confirm" => "MHLW work Can do / common clarification skill",
    "danger_stop" => "MHLW standard curriculum level 1 safety signs",
    "late_absent_health" => "MHLW standard curriculum level 1 absence contact",
    "greetings" => "MHLW standard curriculum level 1 greetings",
    "self_intro" => "MHLW standard curriculum level 1 self introduction",
    "time_work" => "MHLW standard curriculum level 1 time and place notices",
    "numbers_units" => "MHLW standard curriculum level 1 numbers and quantities",
    "tools_places" => "MHLW standard curriculum level 1 work instructions",
    "safety_signs" => "MHLW standard curriculum level 1 safety signs",
    "report_contact" => "MHLW work Can do / reporting work status",
    "commute_daily" => "Life Can do / daily work contact",
    "hospital_disaster" => "Life Can do / emergency contact"
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
      phrases = build_phrases(data.id, samples)

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
        can_do: build_can_do(data, locale),
        pre_task: build_pre_task(samples, locale),
        phrases:,
        dialogue_lines: build_dialogue_lines(samples, locale),
        practice: build_practice(samples, locale),
        role_play: build_role_play(samples, locale),
        reflection: build_reflection(samples, locale),
        self_assessment_options: build_self_assessment_options(locale),
        quiz_questions: build_quiz_questions(samples, locale)
      }
    end

    def build_can_do(data, locale)
      {
        code: format("WN-A1-%<position>02d", position: data.id),
        level: "A1",
        activity_code: ACTIVITY_CODES.fetch(data.key),
        activity_label: I18n.t("lesson_detail.activities.#{ACTIVITY_CODES.fetch(data.key)}", locale:),
        statement: I18n.t("lessons.#{data.key}.objective", locale:),
        framework_reference: FRAMEWORK_REFERENCES.fetch(data.key),
        adapted: I18n.t("lesson_detail.framework_adapted", locale:)
      }
    end

    def build_pre_task(samples, locale)
      I18n.t(
        "lesson_detail.pre_task_body",
        locale:,
        phrase: samples[0],
        response: samples[5]
      )
    end

    def build_phrases(lesson_id, samples)
      [
        phrase(lesson_id, 1, samples[0], samples[1], samples[2], samples[3], samples[4], "lesson_detail.note_primary"),
        phrase(lesson_id, 2, samples[5], samples[6], samples[7], samples[8], samples[9], "lesson_detail.note_secondary")
      ]
    end

    def phrase(lesson_id, id, japanese, kana, en, vi, zh, note_key)
      {
        id:,
        japanese:,
        kana:,
        translation: { ja: japanese, en:, vi:, zh: },
        note: I18n.t(note_key),
        audio: format("/audio/demo/lesson-%<lesson>02d-phrase-%<phrase>02d.m4a", lesson: lesson_id, phrase: id)
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

    def build_practice(samples, locale)
      [
        I18n.t("lesson_detail.practice_repeat", locale:, phrase: samples[0]),
        I18n.t("lesson_detail.practice_replace", locale:, phrase: samples[5])
      ]
    end

    def build_role_play(samples, locale)
      {
        instruction: I18n.t("lesson_detail.role_play_body", locale:, phrase: samples[5]),
        checklist: %w[understand ask repeat next_action].map do |key|
          I18n.t("lesson_detail.role_play_checklist.#{key}", locale:)
        end
      }
    end

    def build_reflection(samples, locale)
      I18n.t("lesson_detail.reflection_body", locale:, phrase: samples[5])
    end

    def build_self_assessment_options(locale)
      (1..4).map do |rating|
        {
          rating:,
          label: I18n.t("lesson_detail.self_assessment_options.#{rating}", locale:)
        }
      end
    end

    def build_quiz_questions(samples, locale)
      [
        meaning_question(1, samples, 0, 5, locale),
        meaning_question(2, samples, 5, 0, locale),
        japanese_choice_question(3, samples, 0, 5, locale),
        japanese_choice_question(4, samples, 5, 0, locale)
      ]
    end

    def meaning_question(id, samples, source_index, other_index, locale)
      effective_locale = locale.to_sym
      correct = translated(samples, source_index, effective_locale)
      other = translated(samples, other_index, effective_locale)

      {
        id:,
        kana: "「#{samples[source_index + 1]}」の いみは どれですか。",
        question: I18n.t("quiz.meaning_question", locale:, phrase: samples[source_index]),
        option_locale: "learner",
        options: options_for(correct, other, effective_locale),
        answer: 1
      }
    end

    def japanese_choice_question(id, samples, source_index, other_index, locale)
      {
        id:,
        kana: "どの にほんごを つかいますか。",
        question: I18n.t("quiz.japanese_choice_question", locale:, meaning: translated(samples, source_index, locale)),
        option_locale: "ja",
        options: options_for(samples[source_index], samples[other_index], :ja),
        answer: 1
      }
    end

    def options_for(correct, other, locale)
      pool = DISTRACTOR_POOLS.fetch(locale.to_sym, DISTRACTOR_POOLS[:en])
      distractor = pool.find { |candidate| candidate != correct && candidate != other } || pool.first

      [correct, other, distractor].uniq
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
