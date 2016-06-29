class CommentairesController < ApplicationController

  def create
    commentaire = @projet_courant.commentaires.build(corps_message: params[:commentaire][:corps_message])
    commentaire.auteur = @utilisateur_courant
    commentaire.save
    redirect_to projet_path(commentaire.projet, jeton: params[:jeton])
  end

end
