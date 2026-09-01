require "set"
require "yaml"

module Content
  class Validator
    REQUIRED_LOCALES = %w[ja en vi].freeze
    VALID_OPTION_LOCALES = %w[learner ja].freeze

    def initialize(paths: Rails.root.glob("db/content/**/*.yml"))
      @paths = Array(paths)
      @result = ValidationResult.new
      @question_fingerprints = {}
    end

    def call
      if @paths.empty?
        @result.add(
          severity: :error,
          file: "db/content",
          field: "files",
          reason: "教材YAMLが見つかりません"
        )
        return @result
      end

      @paths.each { |path| validate_file(path) }
      @result
    end

    private

    def validate_file(path)
      data = YAML.safe_load_file(path, permitted_classes: [Date], aliases: false)
      lessons = data.fetch("lessons", [])
      file = path.to_s

      unless lessons.is_a?(Array)
        add_error(file:, field: "lessons", reason: "lessons must be an array")
        return
      end

      each_duplicate(lessons.filter_map { |lesson| lesson["slug"] }) do |slug|
        add_error(file:, lesson_slug: slug, field: "slug", reason: "duplicate lesson slug")
      end

      lessons.each { |lesson| validate_lesson(file, lesson) }
    rescue Psych::Exception, KeyError => e
      add_error(file: path.to_s, field: "yaml", reason: e.message)
    end

    def validate_lesson(file, lesson)
      slug = lesson["slug"]
      published = truthy?(lesson["published"])
      phrases = Array(lesson["phrases"])
      dialogues = Array(lesson["dialogues"])
      quizzes = Array(lesson["quizzes"])
      phrase_ids = Set.new(phrases.filter_map { |phrase| phrase["id"] })
      dialogue_line_ids = dialogue_line_ids(dialogues)

      %w[slug content_version title objective estimated_minutes].each do |field|
        add_error(file:, lesson_slug: slug, field:, reason: "is required") if blank?(lesson[field])
      end

      validate_i18n(file:, lesson_slug: slug, content_id: slug, field: "title", value: lesson["title"])
      validate_i18n(file:, lesson_slug: slug, content_id: slug, field: "objective", value: lesson["objective"])
      validate_standard_counts(file:, lesson_slug: slug, published:, phrases:, dialogues:, quizzes:)
      validate_duplicate_ids(file:, lesson_slug: slug, collection: phrases, field: "phrases")
      validate_dialogues(file:, lesson_slug: slug, dialogues:)
      validate_duplicate_ids(file:, lesson_slug: slug, collection: quizzes, field: "quizzes")

      quizzes.each do |quiz|
        validate_quiz(file:, lesson_slug: slug, quiz:, phrase_ids:, dialogue_line_ids:)
      end
    end

    def validate_standard_counts(file:, lesson_slug:, published:, phrases:, dialogues:, quizzes:)
      checks = [
        ["phrases", phrases.length, 5..8],
        ["dialogue_lines", dialogues.sum { |dialogue| Array(dialogue["lines"]).length }, 4..8],
        ["quizzes", quizzes.length, 3..5]
      ]

      checks.each do |field, count, range|
        next if range.cover?(count)

        severity = published ? :error : :warning
        @result.add(
          severity:,
          file:,
          lesson_slug:,
          field:,
          reason: "standard count is #{range}; found #{count}"
        )
      end
    end

    def validate_dialogues(file:, lesson_slug:, dialogues:)
      validate_duplicate_ids(file:, lesson_slug:, collection: dialogues, field: "dialogues")

      dialogues.each do |dialogue|
        validate_i18n(file:, lesson_slug:, content_id: dialogue["id"], field: "dialogue.title", value: dialogue["title"])
        validate_duplicate_ids(file:, lesson_slug:, collection: Array(dialogue["lines"]), field: "dialogue_lines")
      end
    end

    def validate_quiz(file:, lesson_slug:, quiz:, phrase_ids:, dialogue_line_ids:)
      quiz_id = quiz["id"]
      option_locale = quiz["option_locale"]
      options = Array(quiz["options"])

      %w[id kind option_locale question_ja options].each do |field|
        add_error(file:, lesson_slug:, content_id: quiz_id, field:, reason: "is required") if blank?(quiz[field])
      end

      unless VALID_OPTION_LOCALES.include?(option_locale)
        add_error(file:, lesson_slug:, content_id: quiz_id, field: "option_locale", reason: "must be learner or ja")
      end

      validate_quiz_source(file:, lesson_slug:, quiz:, phrase_ids:, dialogue_line_ids:)
      validate_reuse(file:, lesson_slug:, quiz:)
      validate_duplicate_ids(file:, lesson_slug:, collection: options, field: "quiz_options")
      validate_options(file:, lesson_slug:, quiz_id:, option_locale:, options:)
      validate_question_fingerprint(file:, lesson_slug:, quiz:)
    end

    def validate_quiz_source(file:, lesson_slug:, quiz:, phrase_ids:, dialogue_line_ids:)
      quiz_id = quiz["id"]
      source_phrase_id = quiz["source_phrase_id"]
      source_dialogue_line_id = quiz["source_dialogue_line_id"]

      if blank?(source_phrase_id) == blank?(source_dialogue_line_id)
        add_error(file:, lesson_slug:, content_id: quiz_id, field: "source", reason: "exactly one source is required")
      elsif source_phrase_id.present? && !phrase_ids.include?(source_phrase_id)
        add_error(file:, lesson_slug:, content_id: quiz_id, field: "source_phrase_id", reason: "must refer to a phrase in the same lesson")
      elsif source_dialogue_line_id.present? && !dialogue_line_ids.include?(source_dialogue_line_id)
        add_error(file:, lesson_slug:, content_id: quiz_id, field: "source_dialogue_line_id", reason: "must refer to a dialogue line in the same lesson")
      end
    end

    def validate_reuse(file:, lesson_slug:, quiz:)
      return unless truthy?(quiz["reuse_allowed"]) && blank?(quiz["reuse_reason"])

      add_error(file:, lesson_slug:, content_id: quiz["id"], field: "reuse_reason", reason: "is required when reuse_allowed is true")
    end

    def validate_options(file:, lesson_slug:, quiz_id:, option_locale:, options:)
      if options.length < 2
        add_error(file:, lesson_slug:, content_id: quiz_id, field: "options", reason: "must have at least 2 options")
      end

      correct_count = options.count { |option| truthy?(option["correct"]) }
      if correct_count != 1
        add_error(file:, lesson_slug:, content_id: quiz_id, field: "options.correct", reason: "must have exactly one correct option")
      end

      options.each do |option|
        text = option["text"] || {}
        if option_locale == "ja"
          add_error(file:, lesson_slug:, content_id: option["id"], field: "text.ja", reason: "is required") if blank?(text["ja"])
        elsif option_locale == "learner"
          REQUIRED_LOCALES.each do |locale|
            add_error(file:, lesson_slug:, content_id: option["id"], field: "text.#{locale}", reason: "is required") if blank?(text[locale])
          end
        end
      end
    end

    def validate_question_fingerprint(file:, lesson_slug:, quiz:)
      options = Array(quiz["options"])
      correct = options.find { |option| truthy?(option["correct"]) }
      fingerprint = [
        quiz["question_ja"].to_s.strip,
        correct&.dig("text", "ja").to_s.strip,
        options.map { |option| option.dig("text", "ja").to_s.strip }.sort
      ]

      return if fingerprint.any?(&:blank?)

      previous = @question_fingerprints[fingerprint]
      if previous && previous[:lesson_slug] != lesson_slug && !truthy?(quiz["reuse_allowed"])
        add_error(
          file:,
          lesson_slug:,
          content_id: quiz["id"],
          field: "question_set",
          reason: "duplicates #{previous[:lesson_slug]} #{previous[:quiz_id]} without reuse_allowed"
        )
      else
        @question_fingerprints[fingerprint] = { lesson_slug:, quiz_id: quiz["id"] }
      end
    end

    def validate_i18n(file:, lesson_slug:, content_id:, field:, value:)
      REQUIRED_LOCALES.each do |locale|
        add_error(file:, lesson_slug:, content_id:, field: "#{field}.#{locale}", reason: "is required") if !value.is_a?(Hash) || blank?(value[locale])
      end
    end

    def validate_duplicate_ids(file:, lesson_slug:, collection:, field:)
      each_duplicate(Array(collection).filter_map { |item| item["id"] }) do |id|
        add_error(file:, lesson_slug:, content_id: id, field:, reason: "duplicate id")
      end
    end

    def dialogue_line_ids(dialogues)
      dialogues.each_with_object(Set.new) do |dialogue, ids|
        Array(dialogue["lines"]).each { |line| ids << line["id"] }
      end
    end

    def each_duplicate(values)
      seen = Set.new
      values.each do |value|
        yield value if seen.include?(value)
        seen << value
      end
    end

    def add_error(file:, reason:, lesson_slug: nil, content_id: nil, field: nil)
      @result.add(severity: :error, file:, lesson_slug:, content_id:, field:, reason:)
    end

    def blank?(value)
      value.respond_to?(:blank?) ? value.blank? : value.nil? || value == ""
    end

    def truthy?(value)
      value == true || value.to_s == "true"
    end
  end
end
