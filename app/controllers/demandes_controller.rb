class DemandesController < ApplicationController
  layout "inscription"

  before_action :assert_projet_courant
  load_and_authorize_resource
  # skip_load_and_authorize_resource only: [:show]

  before_action do
    set_current_registration_step Projet::STEP_DEMANDE
  end
  before_action :init_demande


  def show
    if @projet_courant.eligibilite == 2
      @eligible = false
      fetch_pris_eie
      render 'eligibilities/a_reevaluer' and return
    end
    init_show
  end


  def show_non_eligible
    @projet_courant.reload
    @projet_courant.update(:eligibilite => 2)
    @eligible = false
    fetch_pris_eie
    render 'eligibilities/a_reevaluer' and return
  end

  def show_a_reevaluer
    @projet_courant.reload
    if params[:eligibility].present? && params[:eligibility] == "situation_changed"
      commentaire = "Informations du demandeur :<br>"
      if params[:other_details].present? && params[:situation].present?
        commentaire += "Autres : "
        commentaire += params[:other_details]
      elsif params[:situation].present?
        commentaire += params[:situation]
      else
        flash[:alert] = "Veuillez entrer des Informations"
        redirect_to projet_or_dossier_demande_path and return
      end
      @projet_courant.update(:eligibilite => 1, :eligibility_commentaire => commentaire)
      init_show
      redirect_to projet_or_dossier_demande_path and return
    elsif params[:eligibility].present? && params[:eligibility] == "situation_not_changed"
      redirect_to :action => 'show_non_eligible'  and return
    else
      redirect_to projet_eligibility_path and return
    end
  end

  def update

    @demande.update_attributes(demande_params)

    if @projet_courant.locked_at.blank?
      @projet_courant.update_attributes(locked_at: Time.now)
    end

    if @demande.changement_chauffage == true || @demande.froid == true || @demande.travaux_fenetres == true || @demande.travaux_isolation_murs == true || @demande.travaux_isolation_combles == true || @demande.travaux_isolation == true || @demande.travaux_chauffage
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
    redirect_to_next_step and return
  end

  def show_eligible_hma
    
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
      :travaux_isolation_murs,
      :travaux_isolation_combles,
      :travaux_isolation,
      :travaux_chauffage,
      :travaux_adaptation_sdb,
      :travaux_monte_escalier,
      :travaux_amenagement_ext,
      :travaux_autres,
      :complement,
      :annee_construction,
      :ptz,
      :type_logement,
      :date_achevement_15_ans,
      :prime_hma,
      :devis_rge
    )
  end

  def needs_next_step?
    (@projet_courant.contacted_operateur.blank? && @projet_courant.invited_pris.blank?) || @projet_courant.eligibilite == 1
  end

  def redirect_to_next_step
    if needs_next_step?
      @demande = @projet_courant.demande
      if @demande.eligible_hma_first_step? && @demande.devis_rge && (ENV['ELIGIBLE_HMA'] == 'true')
        render :show_eligible_hma and return
      end
      redirect_to new_user_registration_path and return
    else
      redirect_to projet_or_dossier_path @projet_courant and return
    end
  end

  def fetch_pris_eie
    if ENV['ROD_ENABLED'] == 'true'
      @projet_courant.reload
      rod_response = Rod.new(RodClient).query_for(@projet_courant)
      @pris = rod_response.pris_eie
    end
  end

end

