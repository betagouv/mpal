class DemandesController < ApplicationController
  layout "inscription"

  before_action :assert_projet_courant
  load_and_authorize_resource

  before_action do
    set_current_registration_step Projet::STEP_DEMANDE
  end
  before_action :init_demande

  def show
    init_show
  end

  def update

    @demande.update_attributes(demande_params)

    if @projet_courant.locked_at.blank?
      @projet_courant.update_attributes(locked_at: Time.now)
    end

    if @demande.changement_chauffage == true || @demande.froid == true || @demande.travaux_fenetres == true || @demande.travaux_isolation == true || @demande.travaux_chauffage
      if not (@projet_courant.themes).include?(Theme.find_by(:libelle => "Énergie"))
        @projet_courant.themes << Theme.find_by(:libelle => "Énergie")
      end
    end

    if @demande.probleme_deplacement == true || @demande.accessibilite == true || @demande.hospitalisation == true || @demande.adaptation_salle_de_bain == true || @demande.travaux_adaptation_sdb == true || @demande.travaux_monte_escalier == true || @demande.travaux_amenagement_ext == true
      if not (@projet_courant.themes).include?(Theme.find_by(:libelle => "Autonomie"))
        @projet_courant.themes << Theme.find_by(:libelle => "Autonomie")
      end
    end

    if @demande.arrete == true || @demande.saturnisme == true
      if not (@projet_courant.themes).include?(Theme.find_by(:libelle => "SSH - petite LHI"))
        @projet_courant.themes << Theme.find_by(:libelle => "SSH - petite LHI")
      end
    end

    unless @demande.save
      init_show
      return render :show
    end
    redirect_to_next_step
  end

private
  def init_demande
    @demande = @projet_courant.demande || @projet_courant.build_demande
  end

  def init_show
    @page_heading = "Ma demande"
    @action_label = action_label
  end

  def action_label
    if needs_next_step?
      t('demarrage_projet.action')
    else
      t('projets.edition.action')
    end
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

  def needs_next_step?
    @projet_courant.contacted_operateur.blank? && @projet_courant.invited_pris.blank?
  end

  def redirect_to_next_step
    if needs_next_step?
      redirect_to new_user_registration_path
    else
      redirect_to projet_or_dossier_path @projet_courant
    end
  end
end

