module ProjetConcern
  extend ActiveSupport::Concern

  included do

private

    def render_show
      gon.push({
        latitude:  @projet_courant.adresse.try(:latitude),
        longitude: @projet_courant.adresse.try(:longitude)
      })
      define_helps
      @public_helps_sum = @public_helps_with_amounts.sum(:amount)
      @fundings_sum  = @public_helps_sum
      @fundings_sum += @projet_courant.personal_funding_amount || 0
      @fundings_sum += @projet_courant.loan_amount || 0
      @intervenants_disponibles = @projet_courant.intervenants_disponibles(role: :operateur).shuffle
      @commentaire = Commentaire.new(projet: @projet_courant)
      @pris_departement = @projet_courant.intervenants_disponibles(role: :pris)
      @invitations_demandeur = Invitation.where(projet_id: @projet_courant.id)
      render "projets/show"
    end

    def define_helps
      helps_with_amounts = aides_with_amounts
      @public_helps_with_amounts  = helps_with_amounts.try(:public_assistance)
      @private_helps_with_amounts = helps_with_amounts.try(:not_public_assistance)
    end

    def prestations_with_choices
      # This query be simplified by using `left_joins` once we'll be running on Rails 5
      Prestation
        .active_for_projet(@projet_courant)
        .joins("LEFT OUTER JOIN prestation_choices ON prestation_choices.prestation_id = prestations.id AND prestation_choices.projet_id = #{ActiveRecord::Base.sanitize(@projet_courant.id)}")
        .distinct
        .select('prestations.*, prestation_choices.desired AS desired, prestation_choices.recommended AS recommended, prestation_choices.selected AS selected, prestation_choices.id AS prestation_choice_id')
        .order(:id)
    end

    def aides_with_amounts
      # This query be simplified by using `left_joins` once we'll be running on Rails 5
      Aide
        .active_for_projet(@projet_courant)
        .joins("LEFT OUTER JOIN projet_aides ON projet_aides.aide_id = aides.id AND projet_aides.projet_id = #{ActiveRecord::Base.sanitize(@projet_courant.id)}")
        .distinct
        .select('aides.*, projet_aides.amount AS amount')
        .order(:id)
    end
  end
end
