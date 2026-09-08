class SkillCertificatePdf
  PAGE_WIDTH = 595
  PAGE_HEIGHT = 842

  def self.render(report)
    new(report).render
  end

  def initialize(report)
    @report = report
  end

  def render
    objects = []
    objects << "<< /Type /Catalog /Pages 2 0 R >>"
    objects << "<< /Type /Pages /Kids [3 0 R] /Count 1 >>"
    objects << "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 #{PAGE_WIDTH} #{PAGE_HEIGHT}] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>"
    objects << "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"
    objects << "<< /Length #{content.bytesize} >>\nstream\n#{content}\nendstream"

    build_pdf(objects)
  end

  private

  attr_reader :report

  def content
    @content ||= begin
      text_lines = [
        ["Skill Certificate", 24],
        ["Work Nihongo learning record", 15],
        ["Learner: #{report.user[:display_name]}", 12],
        ["Issued on: #{report.issued_on.iso8601}", 12],
        ["Completed lessons: #{report.completed_count} / #{report.total_lessons} (#{report.completion_rate}%)", 12],
        ["Comprehension passed: #{report.passed_count} / #{report.total_lessons} (#{report.pass_rate}%)", 12],
        ["Self-assessed Can do: #{report.assessed_count} / #{report.total_lessons} (#{report.self_assessment_rate}%)", 12],
        ["Best score: #{report.highest_score || '-'}", 12],
        ["Average score: #{report.average_score || '-'}", 12],
        ["This document is not an official Japanese level certification.", 11],
        ["It records web learning activity, quiz results, and self-assessment only.", 11]
      ]

      y = 760
      commands = ["BT"]
      text_lines.each do |text, size|
        commands << "/F1 #{size} Tf"
        commands << "72 #{y} Td (#{escape(text)}) Tj"
        y -= size >= 15 ? 32 : 22
      end
      commands << "ET"
      commands.join("\n")
    end
  end

  def build_pdf(objects)
    body = +"%PDF-1.4\n"
    offsets = [0]

    objects.each_with_index do |object, index|
      offsets << body.bytesize
      body << "#{index + 1} 0 obj\n#{object}\nendobj\n"
    end

    xref_offset = body.bytesize
    body << "xref\n0 #{objects.length + 1}\n"
    body << "0000000000 65535 f \n"
    offsets.drop(1).each do |offset|
      body << format("%010d 00000 n \n", offset)
    end
    body << "trailer\n<< /Size #{objects.length + 1} /Root 1 0 R >>\n"
    body << "startxref\n#{xref_offset}\n%%EOF\n"
    body
  end

  def escape(text)
    text.to_s.encode("Windows-1252", invalid: :replace, undef: :replace, replace: "-")
        .gsub("\\", "\\\\\\")
        .gsub("(", "\\(")
        .gsub(")", "\\)")
  end
end
