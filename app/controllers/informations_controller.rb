class InformationsController < ApplicationController
  layout "informations"

  before_action do
    @projet = current_user&.projet_as_demandeur || Projet.find_by_id(session[:project_id])
  end

  def faq
    @page_heading = t("menu.faq")
  end

  def terms_of_use
    @page_heading = t("menu.terms_of_use")
  end

  def legal
    @page_heading = t("menu.legal")
  end

  def stats
    @page_heading = t("menu.stats")
    @project_count = Projet.count
    project_statuses = Projet.updated_since(1.month.ago).map(&:status_for_intervenant)
    status_count = Projet::INTERVENANT_STATUSES.map { |status| project_statuses.count status }
    @project_count_by_status = Projet::INTERVENANT_STATUSES.zip(status_count).to_h
  end

  def robots
    respond_to :text
  end
end
