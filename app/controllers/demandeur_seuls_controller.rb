class DemandeurSeulsController < ApplicationController
  include ProjetConcern

  before_action :assert_projet_courant
  before_action :assert_demande_seul
  load_and_authorize_resource class: "Projet"

  def show
    gon.push({
        latitude:  @projet_courant.adresse.try(:latitude),
        longitude: @projet_courant.adresse.try(:longitude)
    })

    aids = @projet_courant.aids_with_amounts
    @public_aids_with_amounts = aids.try(:public_assistance)
    @private_aids_with_amounts = aids.try(:not_public_assistance)

    @public_aids_sum = @public_aids_with_amounts.sum(:amount)
    @fundings_sum  = @public_aids_sum
    @fundings_sum += @projet_courant.personal_funding_amount || 0
    @fundings_sum += @projet_courant.loan_amount || 0
    @fundings_sum += @private_aids_with_amounts.sum(:amount)

    @remaining_sum = @projet_courant.global_ttc_sum
    @remaining_sum -= @fundings_sum || 0
    @global_ht_sum = @projet_courant.travaux_ht_amount || 0
    @intervenants_disponibles = @projet_courant.intervenants_disponibles(role: :operateur).shuffle
    @pris_departement = @projet_courant.intervenants_disponibles(role: :pris)
    @invitations_demandeur = Invitation.where(projet_id: @projet_courant.id)
    render "projets/show_hma_ds" and return
  end

  def proposer
    if (ENV['ELIGIBLE_HMA'] == 'true' && @projet_courant.hma.present? && @projet_courant.save(context: :proposition_hma))
      redirect_to projet_transmission_path(@projet_courant)
    else
      render_proposition
    end
  end

  def proposition
    if @projet_courant.prospect?
      return redirect_to root_path, alert: t('sessions.access_forbidden')
    end
    if request.put?
      @projet_courant.statut = :proposition_proposee
      if ((ENV['ELIGIBLE_HMA'] == 'true') && (@projet_courant.demande.eligible_hma)) && @projet_courant.update_attributes(projet_params_hma)
          return redirect_to root_path, notice: t('projets.edition_projet.messages.succes')
      else
        flash.now[:alert] = t('projets.edition_projet.messages.erreur')
      end
    end
    render_proposition
  end

  private

  def clean_projet_aides(attributes)
    if attributes[:projet_aides_attributes].present?
      attributes[:projet_aides_attributes].values.each do |projet_aide|
        projet_aide_to_modify = ProjetAide.where(aide_id: projet_aide[:aide_id], projet_id: @projet_courant.id).first
        projet_aide[:id] = projet_aide_to_modify.try(:id)
        amount = projet_aide[:localized_amount]
        projet_aide[:_destroy] = true if amount.blank? || BigDecimal(amount) == 0
      end
    end
    attributes
  end

  def projet_params_hma
    attributes = params.require(:projet).permit(
        :numero_siret, :nom_entreprise, :cp_entreprise,
        :precisions_travaux, :precisions_financement,
        :localized_loan_amount, :localized_personal_funding_amount,
        :hma_attributes => [:id, :devis_ht, :devis_ttc, :moa, :ptz],
        :suggested_operateur_ids => [],
        :projet_aides_attributes => [:aide_id, :localized_amount]
    )
    clean_projet_aides(attributes)
    attributes
  end

  def render_proposition

    aids = @projet_courant.aids_with_amounts
    @public_aids_with_amounts = aids.try(:public_assistance)
    @private_aids_with_amounts = aids.try(:not_public_assistance)

    unless @projet_courant.projet_aides.any?
      Aide.active_for_projet(@projet_courant).ordered.each do |aide|
        @projet_courant.projet_aides.build(aide: aide)
      end
    end
    @page_heading = "Projet proposé par l’opérateur"
    render "projets/proposition_hma_ds" and return
  end

  def assert_demande_seul
    if !(ENV['ELIGIBLE_HMA'] == 'true' && @projet_courant.demande && @projet_courant.demande.seul && @projet_courant.users.include?(current_user))
      return redirect_to root_path, alert: t('sessions.access_forbidden')
    end
  end

end