module Content
  class ValidationResult
    attr_reader :issues

    def initialize
      @issues = []
    end

    def add(severity:, file:, lesson_slug: nil, content_id: nil, field: nil, reason:)
      issues << ValidationIssue.new(severity:, file:, lesson_slug:, content_id:, field:, reason:)
    end

    def errors
      issues.select(&:error?)
    end

    def warnings
      issues.reject(&:error?)
    end

    def success?
      errors.empty?
    end
  end
end
