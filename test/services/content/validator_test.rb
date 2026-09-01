require "test_helper"
require "tmpdir"

class Content::ValidatorTest < ActiveSupport::TestCase
  test "detects duplicate ids in the same lesson" do
    result = validate_yaml(lesson_yaml(phrases: [phrase("p01"), phrase("p01")]))

    assert result.errors.any? { |issue| issue.field == "phrases" && issue.reason == "duplicate id" }
  end

  test "detects quiz source outside the same lesson" do
    result = validate_yaml(lesson_yaml(quizzes: [quiz("q01", source_phrase_id: "missing")]))

    assert result.errors.any? { |issue| issue.field == "source_phrase_id" }
  end

  test "detects repeated question sets across lessons unless reuse is allowed" do
    yaml = base_yaml([
      lesson_hash("lesson-one", quizzes: [quiz("q01")]),
      lesson_hash("lesson-two", quizzes: [quiz("q01")])
    ])

    result = validate_yaml(yaml)

    assert result.errors.any? { |issue| issue.field == "question_set" }
  end

  test "allows repeated question sets with reuse reason" do
    yaml = base_yaml([
      lesson_hash("lesson-one", quizzes: [quiz("q01")]),
      lesson_hash("lesson-two", quizzes: [quiz("q01", reuse_allowed: true, reuse_reason: "Company-wide safety phrase")])
    ])

    result = validate_yaml(yaml)

    assert result.errors.none? { |issue| issue.field == "question_set" }
  end

  test "published lessons fail when standard counts are missing" do
    result = validate_yaml(lesson_yaml(published: true))

    assert result.errors.any? { |issue| issue.field == "phrases" }
    assert result.errors.any? { |issue| issue.field == "dialogue_lines" }
    assert result.errors.any? { |issue| issue.field == "quizzes" }
  end

  test "draft lessons warn but do not fail for missing standard counts" do
    result = validate_yaml(lesson_yaml(published: false))

    assert result.success?
    assert result.warnings.any? { |issue| issue.field == "phrases" }
  end

  test "reports file lesson content id field and reason" do
    result = validate_yaml(lesson_yaml(quizzes: [quiz("q01", option_locale: "bad")]))
    issue = result.errors.find { |candidate| candidate.field == "option_locale" }

    assert_match(/content.yml/, issue.file)
    assert_equal "ask-confirm", issue.lesson_slug
    assert_equal "q01", issue.content_id
    assert_equal "must be learner or ja", issue.reason
  end

  private

  def validate_yaml(yaml)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "content.yml")
      File.write(path, yaml)
      return Content::Validator.new(paths: [Pathname(path)]).call
    end
  end

  def lesson_yaml(overrides = {})
    base_yaml([lesson_hash("ask-confirm", **overrides)])
  end

  def base_yaml(lessons)
    {
      "course" => { "slug" => "work", "title" => { "ja" => "仕事", "en" => "Work", "vi" => "Cong viec" } },
      "lessons" => lessons
    }.to_yaml
  end

  def lesson_hash(slug, phrases: [phrase("p01")], dialogues: [dialogue], quizzes: [quiz("q01")], published: false)
    {
      "slug" => slug,
      "content_version" => 1,
      "published" => published,
      "estimated_minutes" => 7,
      "title" => { "ja" => "確認", "en" => "Confirm", "vi" => "Xac nhan" },
      "objective" => { "ja" => "確認する", "en" => "Confirm", "vi" => "Xac nhan" },
      "phrases" => phrases,
      "dialogues" => dialogues,
      "quizzes" => quizzes
    }
  end

  def phrase(id)
    {
      "id" => id,
      "japanese" => "分かりません。",
      "kana" => "わかりません。",
      "translation" => { "ja" => "分かりません。", "en" => "I do not understand.", "vi" => "Toi khong hieu." }
    }
  end

  def dialogue
    {
      "id" => "d01",
      "title" => { "ja" => "会話", "en" => "Dialogue", "vi" => "Hoi thoai" },
      "lines" => [
        {
          "id" => "dl01",
          "speaker" => "learner",
          "japanese" => "もう一度お願いします。",
          "kana" => "もういちど おねがいします。",
          "translation" => { "ja" => "もう一度お願いします。", "en" => "Please say it again.", "vi" => "Xin hay noi lai." }
        }
      ]
    }
  end

  def quiz(id, attributes = {})
    {
      "id" => id,
      "kind" => "meaning",
      "option_locale" => "learner",
      "source_phrase_id" => "p01",
      "reuse_allowed" => false,
      "question_ja" => "「分かりません。」の意味はどれですか。",
      "question" => { "ja" => "意味はどれですか。", "en" => "What does it mean?", "vi" => "Nghia la gi?" },
      "explanation" => { "ja" => "分からない時に使います。", "en" => "Use this when you do not understand.", "vi" => "Dung khi khong hieu." },
      "options" => [
        { "id" => "o01", "correct" => true, "text" => { "ja" => "分かりません。", "en" => "I do not understand.", "vi" => "Toi khong hieu." } },
        { "id" => "o02", "correct" => false, "text" => { "ja" => "終わりました。", "en" => "I finished.", "vi" => "Toi da xong." } }
      ]
    }.merge(attributes.stringify_keys)
  end
end
