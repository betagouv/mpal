module ProjetConcern
  extend ActiveSupport::Concern

  included do
    private
    def render_show
      gon.push({
        latitude:  @projet_courant.adresse.try(:latitude),
        longitude: @projet_courant.adresse.try(:longitude)
      })

      global_ttc_parts = [:travaux_ttc_amount, :amo_amount, :maitrise_oeuvre_amount]
      @global_ttc_sum = global_ttc_parts.map{ |column| @projet_courant[column] }.compact.reduce(:+)

      aids = @projet_courant.aids_with_amounts
      @public_aids_with_amounts = aids.try(:public_assistance)
      @private_aids_with_amounts = aids.try(:not_public_assistance)

      @public_aids_sum = @public_aids_with_amounts.sum(:amount)
      @fundings_sum  = @public_aids_sum
      @fundings_sum += @projet_courant.personal_funding_amount || 0
      @fundings_sum += @projet_courant.loan_amount || 0
      @intervenants_disponibles = @projet_courant.intervenants_disponibles(role: :operateur).shuffle
      @pris_departement = @projet_courant.intervenants_disponibles(role: :pris)
      @invitations_demandeur = Invitation.where(projet_id: @projet_courant.id)
      render "projets/show"
    end
  end
end

