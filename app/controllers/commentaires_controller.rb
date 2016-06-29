class CommentairesController < ApplicationController

  def create
    commentaire = @projet_courant.commentaires.build(corps_message: params[:commentaire][:corps_message])
    commentaire.auteur = @utilisateur_courant
    if commentaire.save
      redirect_to commentaire.projet
    else
      raise "ERROR: #{commentaire.errors.full_messages}"
      
    end 
  end

end
