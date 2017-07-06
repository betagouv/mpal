class DemandeursController < ApplicationController
  layout 'inscription'

  before_action :assert_projet_courant
  authorize_resource :class => false

  def show
    render_show
  end

  def update
    if save_demandeur
      return redirect_to_next_step
    else
      render_show
    end
  end

  def departement_non_eligible
    @departements = Tools::departements_enabled - [Tools::STATES_WILDCARD]
  end

private
  # Show -----------------------

  def render_show
    @projet_courant.personne ||= Personne.new
    @demandeur ||= @projet_courant.demandeur
    @demandeur ||= Occupant.new

    @page_heading = 'Inscription'
    @declarants = @projet_courant.occupants.declarants.collect { |o| [ o.fullname, o.id ] }
    @declarants_prompt = @declarants.length <= 1 ? nil : t('demarrage_projet.demandeur.select')

    render :show
  end

  # Update ---------------------

  def projet_params
    params.require(:projet).permit(
      :tel,
      :email,
    )
  end

  def projet_personne_params
    params.require(:projet).permit(
      personne_attributes: [
        :id,
        :prenom,
        :nom,
        :tel,
        :email,
        :lien_avec_demandeur,
        :civilite
      ]
    )
  end

  def demandeur_params
    params[:projet].fetch(:occupant, {}).permit(:civility)
  end

  def save_demandeur
    begin
      @projet_courant.adresse_postale = ProjetInitializer.new.precise_adresse(
        params[:projet][:adresse_postale],
        previous_value: @projet_courant.adresse_postale,
        required: true
      )

      @projet_courant.adresse_a_renover = ProjetInitializer.new.precise_adresse(
        params[:projet][:adresse_a_renover],
        previous_value: @projet_courant.adresse_a_renover,
        required: false
      )
    rescue => e
      flash.now[:alert] = e.message
      return false
    end

    @projet_courant.assign_attributes(projet_params)
    if "1" == params[:contact]
      @projet_courant.assign_attributes(projet_personne_params)
    else
      if @projet_courant.personne.present?
        personne = @projet_courant.personne
        @projet_courant.update_attribute(:personne_id, nil)
        personne.destroy!
      else
        @projet_courant.personne = nil
      end
    end
    unless @projet_courant.save
      flash.now[:alert] = t('demarrage_projet.demandeur.erreurs.enregistrement_demandeur')
      return false
    end

    demandeur_id = params[:projet][:demandeur]
    if demandeur_id.blank?
      flash.now[:alert] = t('demarrage_projet.demandeur.erreurs.missing_demandeur')
      return false
    end
    if !assign_demandeur(demandeur_id)
      flash.now[:alert] = t('demarrage_projet.demandeur.erreurs.enregistrement_demandeur')
      return false
    end

    true
  end

  def assign_demandeur(demandeur_id)
    @demandeur = @projet_courant.change_demandeur(demandeur_id)
    @demandeur.assign_attributes(demandeur_params)
    @demandeur.save
  end

  def redirect_to_next_step
    if Tools.departement_enabled?(@projet_courant.departement)
      return redirect_to projet_or_dossier_avis_impositions_path(@projet_courant)
    else
      return redirect_to projet_demandeur_departement_non_eligible_path(@projet_courant)
    end
  end
end

