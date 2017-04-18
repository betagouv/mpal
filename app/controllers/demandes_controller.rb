class DemandesController < ApplicationController
  layout 'inscription'

  before_action :dossier_ou_projet
  before_action :assert_projet_courant
  before_action :authentifie

  def show
    @demande = projet_demande
    @page_heading = 'Inscription'
    @action_label = if needs_next_step? then action_label_create else action_label_update end
  end

  def update
    @projet_courant.demande = projet_demande
    if demande_params_valid?
      @projet_courant.demande.update_attributes(demande_params)
      redirect_to_next_step
    else
      redirect_to projet_demande_path(@projet_courant), alert: t('demarrage_projet.demande.erreurs.besoin_obligatoire')
    end
  end

private

  def action_label_create
    t('demarrage_projet.action')
  end

  def action_label_update
    t('projets.edition.action')
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

  def needs_next_step?
    @projet_courant.invited_operateur.blank? && @projet_courant.invited_pris.blank?
  end

  def redirect_to_next_step
    if needs_next_step?
      redirect_to projet_mise_en_relation_path(@projet_courant)
    else
      redirect_to projet_path(@projet_courant)
    end
  end
end
