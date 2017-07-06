class DemandesController < ApplicationController
  layout 'inscription'

  before_action :assert_projet_courant
  load_and_authorize_resource

  def show
    @demande = projet_demande

    @page_heading = 'Inscription'
    @action_label = action_label
  end

  def update
    @projet_courant.demande = projet_demande
    if demande_params_valid?
      @projet_courant.demande.update_attributes(demande_params)
      redirect_to_next_step
    else
      redirect_to projet_or_dossier_demande_path(@projet_courant), alert: t('demarrage_projet.demande.erreurs.besoin_obligatoire')
    end
  end

private

  def action_label
    if needs_next_step?
      t('demarrage_projet.action')
    else
      t('projets.edition.action')
    end
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
      :arrete,
      :saturnisme,
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
    @projet_courant.contacted_operateur.blank? && @projet_courant.invited_pris.blank?
  end

  def redirect_to_next_step
    if needs_next_step?
      redirect_to projet_eligibility_path @projet_courant
    else
      redirect_to projet_or_dossier_path @projet_courant
    end
  end
end

