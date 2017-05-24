class CommentairesController < ApplicationController
  before_action :projet_or_dossier
  before_action :assert_projet_courant
  before_action :authentifie

  def create
    commentaire = @projet_courant.commentaires.build(corps_message: params[:commentaire][:corps_message])
    commentaire.auteur = author
    commentaire.save
    redirect_to projet_or_dossier_path(@projet_courant)
  end

private

  def author
    if agent_signed_in?
      current_agent
    else
      @projet_courant.demandeur
    end
  end
end
