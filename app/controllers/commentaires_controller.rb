class CommentairesController < ApplicationController
  before_action :projet_or_dossier
  before_action :assert_projet_courant
  before_action :authentifie

  def create
    commentaire = @projet_courant.commentaires.build(corps_message: params[:commentaire][:corps_message])
    commentaire.auteur = @utilisateur_courant
    commentaire.save
    redirect_to projet_or_dossier_path(@projet_courant)
  end
end
