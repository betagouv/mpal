module ProjetConcern
  extend ActiveSupport::Concern

  included do
    private
    def render_show
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
      @intervenants_disponibles = @projet_courant.intervenants_disponibles(role: :operateur).shuffle
      @commentaire = Commentaire.new(projet: @projet_courant)
      @pris_departement = @projet_courant.intervenants_disponibles(role: :pris)
      @invitations_demandeur = Invitation.where(projet_id: @projet_courant.id)
      render "projets/show"
    end
  end
end
