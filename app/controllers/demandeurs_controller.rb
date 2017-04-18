class DemandeursController < ApplicationController
  layout 'inscription'

  before_action :projet_or_dossier
  before_action :assert_projet_courant
  before_action :authentifie

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

private
  # Show -----------------------

  def action_label
    if needs_next_step?
      t('demarrage_projet.action')
    else
      t('projets.edition.action')
    end
  end

  def render_show
    @projet_courant.personne ||= Personne.new
    @demandeur ||= @projet_courant.demandeur_principal

    @page_heading = 'Inscription'
    @declarants = @projet_courant.occupants.declarants.collect { |o| [ o.fullname, o.id ] }
    @action_label = action_label

    render :show
  end

  # Update ---------------------

  def projet_params
    params.require(:projet).permit(
      :civilite,
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

  def demandeur_principal_params
    params.fetch(:demandeur_principal, {}).permit(:civilite)
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

    demandeur_id = params[:projet][:demandeur_id]
    needs_saving_demandeur = demandeur_id.present?
    if needs_saving_demandeur && !assign_demandeur(demandeur_id)
      flash.now[:alert] = t('demarrage_projet.demandeur.erreurs.enregistrement_demandeur')
      return false
    end

    true
  end

  def assign_demandeur(demandeur_id)
    @demandeur = @projet_courant.change_demandeur(demandeur_id)
    @demandeur.assign_attributes(demandeur_principal_params)
    @demandeur.save
  end

  def needs_next_step?
    @projet_courant.demande.blank? || ! @projet_courant.demande.complete?
  end

  def redirect_to_next_step
    if needs_next_step?
      redirect_to projet_or_dossier_avis_impositions_path(@projet_courant)
    else
      redirect_to projet_or_dossier_path(@projet_courant)
    end
  end
end
