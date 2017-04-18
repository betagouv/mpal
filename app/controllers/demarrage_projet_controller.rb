class DemarrageProjetController < ApplicationController
  layout 'inscription'

  before_action :dossier_ou_projet
  before_action :assert_projet_courant
  before_action :authentifie
  before_action :init_view

  def demande
    @demande = projet_demande
    @action_label = if needs_mise_en_relation_step? then action_label_create else action_label_update end
  end

  def update_demande
    @projet_courant.demande = projet_demande
    if demande_params_valid?
      @projet_courant.demande.update_attributes(demande_params)
      demande_redirect_to_next_step
    else
      redirect_to projet_demande_path(@projet_courant), alert: t('demarrage_projet.demande.erreurs.besoin_obligatoire')
    end
  end

  def mise_en_relation
    @demande = projet_demande
    @pris_departement = @projet_courant.intervenants_disponibles(role: :pris).first
    if @pris_departement.blank?
      raise "Il n’y a pas de PRIS disponible pour le département #{@projet_courant.departement}"
    end
    @action_label = if needs_mise_en_relation_step? then action_label_create else action_label_update end
  end

  def update_mise_en_relation
    begin
      @projet_courant.update_attribute(:disponibilite, params[:projet][:disponibilite])
      intervenant = Intervenant.find_by_id(params[:intervenant])
      unless @projet_courant.intervenants.include? intervenant
        @projet_courant.invite_intervenant!(intervenant)
        flash[:notice_titre] = t('invitations.messages.succes_titre')
        flash[:notice] = t('invitations.messages.succes', intervenant: intervenant.raison_sociale)
      end
      redirect_to projet_path(@projet_courant)
    rescue => e
      logger.error e.message
      redirect_to projet_mise_en_relation_path(@projet_courant), alert: "Une erreur s’est produite lors de l’enregistrement de l’intervenant."
    end
  end

private
  def init_view
    @page_heading = 'Inscription'
  end

  def projet_demande
    @projet_courant.demande || @projet_courant.build_demande
  end

  def demande_params
    params.require(:demande).permit(
      :changement_chauffage,
      :froid,
      :probleme_deplacement,
      :accessibilite,
      :hospitalisation,
      :adaptation_salle_de_bain,
      :autre,
      :travaux_fenetres,
      :travaux_isolation,
      :travaux_chauffage,
      :travaux_adaptation_sdb,
      :travaux_monte_escalier,
      :travaux_amenagement_ext,
      :travaux_autres,
      :complement,
      :annee_construction,
      :ptz,
      :date_achevement_15_ans
    )
  end

  def demande_params_valid?
    demande_params.values.include?('1')
  end

  def needs_mise_en_relation_step?
    @projet_courant.invited_operateur.blank? && @projet_courant.invited_pris.blank?
  end

  def demande_redirect_to_next_step
    if needs_mise_en_relation_step?
      redirect_to projet_mise_en_relation_path(@projet_courant)
    else
      redirect_to projet_path(@projet_courant)
    end
  end

  def action_label_create
    t('demarrage_projet.action')
  end

  def action_label_update
    t('projets.edition.action')
  end
end
