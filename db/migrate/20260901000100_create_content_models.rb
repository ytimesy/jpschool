class CreateContentModels < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :slug, null: false
      t.jsonb :title_i18n, null: false, default: {}
      t.integer :sort_order, null: false, default: 0
      t.boolean :published, null: false, default: false

      t.timestamps
    end

    add_index :courses, :slug, unique: true

    create_table :lessons do |t|
      t.references :course, null: false, foreign_key: true
      t.string :slug, null: false
      t.jsonb :title_i18n, null: false, default: {}
      t.jsonb :objective_i18n, null: false, default: {}
      t.integer :estimated_minutes, null: false
      t.integer :sort_order, null: false, default: 0
      t.integer :content_version, null: false, default: 1
      t.string :validation_status, null: false, default: "draft"
      t.datetime :reviewed_at
      t.datetime :published_at

      t.timestamps
    end

    add_index :lessons, :slug, unique: true
    add_check_constraint :lessons, "validation_status IN ('draft', 'valid', 'invalid')", name: "lessons_validation_status_check"

    create_table :phrases do |t|
      t.references :lesson, null: false, foreign_key: true
      t.string :content_key, null: false
      t.text :japanese_text, null: false
      t.text :kana_text, null: false
      t.jsonb :translation_i18n, null: false, default: {}
      t.jsonb :note_i18n, null: false, default: {}
      t.string :audio_path
      t.integer :sort_order, null: false, default: 0

      t.timestamps
    end

    add_index :phrases, [:lesson_id, :content_key], unique: true

    create_table :dialogues do |t|
      t.references :lesson, null: false, foreign_key: true
      t.string :content_key, null: false
      t.jsonb :title_i18n, null: false, default: {}
      t.integer :sort_order, null: false, default: 0

      t.timestamps
    end

    add_index :dialogues, [:lesson_id, :content_key], unique: true

    create_table :dialogue_lines do |t|
      t.references :dialogue, null: false, foreign_key: true
      t.string :content_key, null: false
      t.string :speaker, null: false
      t.text :japanese_text, null: false
      t.text :kana_text, null: false
      t.jsonb :translation_i18n, null: false, default: {}
      t.string :audio_path
      t.integer :sort_order, null: false, default: 0

      t.timestamps
    end

    add_index :dialogue_lines, [:dialogue_id, :content_key], unique: true

    create_table :quizzes do |t|
      t.references :lesson, null: false, foreign_key: true
      t.string :content_key, null: false
      t.string :kind, null: false
      t.string :option_locale, null: false
      t.references :source_phrase, foreign_key: { to_table: :phrases }
      t.references :source_dialogue_line, foreign_key: { to_table: :dialogue_lines }
      t.text :question_ja, null: false
      t.text :question_kana
      t.jsonb :question_i18n, null: false, default: {}
      t.jsonb :explanation_i18n, null: false, default: {}
      t.string :audio_path
      t.boolean :reuse_allowed, null: false, default: false
      t.text :reuse_reason
      t.integer :sort_order, null: false, default: 0

      t.timestamps
    end

    add_index :quizzes, [:lesson_id, :content_key], unique: true
    add_check_constraint :quizzes, "option_locale IN ('learner', 'ja')", name: "quizzes_option_locale_check"
    add_check_constraint :quizzes, "(source_phrase_id IS NULL) <> (source_dialogue_line_id IS NULL)", name: "quizzes_one_source_check"

    create_table :quiz_options do |t|
      t.references :quiz, null: false, foreign_key: true
      t.string :content_key, null: false
      t.text :text_ja, null: false
      t.jsonb :text_i18n, null: false, default: {}
      t.boolean :correct, null: false, default: false
      t.integer :sort_order, null: false, default: 0

      t.timestamps
    end

    add_index :quiz_options, [:quiz_id, :content_key], unique: true
  end
end
