class EvaluationsController < ApplicationController
  def show
    @report = evaluation_report
  end

  def certificate
    report = evaluation_report
    send_data(
      SkillCertificatePdf.render(report),
      filename: "work-nihongo-skill-certificate.pdf",
      type: "application/pdf",
      disposition: "attachment"
    )
  end

  private

  def evaluation_report
    EvaluationReport.new(
      lessons: demo_lessons,
      user: demo_user,
      self_assessments: session[:self_assessments] || {}
    )
  end
end
