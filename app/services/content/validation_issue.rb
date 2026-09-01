module Content
  ValidationIssue = Data.define(:severity, :file, :lesson_slug, :content_id, :field, :reason) do
    def error?
      severity == :error
    end

    def to_s
      parts = [
        severity.to_s.upcase,
        file,
        lesson_slug || "-",
        content_id || "-",
        field || "-",
        reason
      ]

      parts.join(" | ")
    end
  end
end
