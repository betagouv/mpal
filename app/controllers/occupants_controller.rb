class OccupantsController < ApplicationController
  layout 'inscription'

  before_action :assert_projet_courant
  load_and_authorize_resource

  def index
    @occupant = @projet_courant.avis_impositions.first.occupants.build(occupant_params)

    if request.post?
      if projet_params.present?
        @projet_courant.update_attributes(projet_params)
      end
      if params[:submit_button].nil?
        if @occupant.save(context: :user_action)
          return redirect_to projet_or_dossier_occupants_path(@projet_courant)
        end
      elsif !occupant_params? || @occupant.save(context: :user_action)
        return redirect_to_next_step
      end
    end

    @occupants = @projet_courant.occupants.to_a.find_all(&:persisted?)
    @action_label = action_label
  end

  def destroy
    @occupant = @projet_courant.occupants.where(id: params[:id]).first

    if @occupant.can_be_deleted? && @occupant.destroy
      flash[:notice] = t("occupants.delete.success", fullname: @occupant.fullname)
    else
      flash[:alert] = t("occupants.delete.error")
    end
    redirect_to projet_or_dossier_occupants_path(@projet_courant)
  end

private

  def action_label
    if needs_next_step?
      t('demarrage_projet.action')
    else
      t('projets.edition.action')
    end
  end

  def projet_params
    params[:occupant].fetch(:projet, {}).permit(
      :future_birth
    )
  end

  def occupant_params
    params.fetch(:occupant, {}).permit(
      :civilite,
      :prenom,
      :nom,
      :date_de_naissance,
      :lien_demandeur,
      :demandeur,
      :revenus
    )
  end

  def occupant_params?
    occupant_params.any? { |attribute, value| value.present? }
  end

  def needs_next_step?
    @projet_courant.demande.blank? || !@projet_courant.demande.complete?
  end

  def redirect_to_next_step
    if needs_next_step?
      redirect_to projet_or_dossier_demande_path(@projet_courant)
    else
      redirect_to projet_or_dossier_path(@projet_courant)
    end
  end
end
