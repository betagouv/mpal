class CommentairesController < ApplicationController

  def create
    @commentaire = projet.commentaires.build(commentaire_params)
    commentaire.auteur = projet
    commentaire.save
  end

  def projet
    @projet ||= Projet.find(params[:projet_id])
  end

  private
  def commentaire_params
    params.require(:projet).permit(:projet_id, :corps_message, :auteur)
  end
end
