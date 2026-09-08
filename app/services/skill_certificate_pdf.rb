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
    objects << "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 #{PAGE_WIDTH} #{PAGE_HEIGHT}] /Resources << /Font << /F1 4 0 R >> >> /Contents 6 0 R >>"
    objects << "<< /Type /Font /Subtype /Type0 /BaseFont /HeiseiKakuGo-W5 /Encoding /UniJIS-UCS2-H /DescendantFonts [5 0 R] >>"
    objects << "<< /Type /Font /Subtype /CIDFontType0 /BaseFont /HeiseiKakuGo-W5 /CIDSystemInfo << /Registry (Adobe) /Ordering (Japan1) /Supplement 5 >> >>"
    objects << "<< /Length #{content.bytesize} >>\nstream\n#{content}\nendstream"

    build_pdf(objects)
  end

  private

  attr_reader :report

  def content
    @content ||= begin
      text_lines = [
        ["スキル証書 / Skill Certificate", 22],
        ["しごと日本語 / Work Nihongo Web学習記録", 14],
        ["学習者: #{report.user[:display_name]}", 11],
        ["発行日: #{report.issued_on.iso8601}", 11],
        ["完了レッスン: #{report.completed_count} / #{report.total_lessons} (#{report.completion_rate}%)", 11],
        ["理解テスト合格: #{report.passed_count} / #{report.total_lessons} (#{report.pass_rate}%)", 11],
        ["Can do自己評価済み: #{report.assessed_count} / #{report.total_lessons} (#{report.self_assessment_rate}%)", 11],
        ["最高点: #{report.highest_score || '-'}", 11],
        ["平均点: #{report.average_score || '-'}", 11],
        ["このPDFはWeb学習、理解テスト、Can do自己評価の記録です。", 10],
        ["日本語能力レベルを公的に認定する証明書ではありません。", 10],
        ["", 8],
        ["Can do別サマリー", 12],
        *lesson_summary_lines
      ]

      y = 760
      commands = ["BT"]
      text_lines.each do |text, size|
        commands << "/F1 #{size} Tf"
        commands << "1 0 0 1 72 #{y} Tm #{pdf_text(text)} Tj"
        y -= size >= 15 ? 32 : 22
      end
      commands << "ET"
      commands.join("\n")
    end
  end

  def lesson_summary_lines
    report.lesson_rows.map do |row|
      score = row[:highest_score] || "-"
      assessment = row[:self_assessment] || "-"
      title = truncate(row[:title], 18)
      can_do = truncate(row[:can_do], 35)

      ["#{row[:position]}. #{title} / 点数 #{score} / 自己評価 #{assessment} / #{can_do}", 8]
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

  def pdf_text(text)
    "<#{text.to_s.encode("UTF-16BE", invalid: :replace, undef: :replace, replace: "?").unpack1("H*").upcase}>"
  end

  def truncate(text, length)
    value = text.to_s
    return value if value.length <= length

    "#{value.first(length - 1)}…"
  end
end
