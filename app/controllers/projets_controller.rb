class ProjetsController < ApplicationController
  def new
    @projet = Projet.new
  end

  def create
    @projet = Projet.new(params[:projet])
    @projet.valid? ? render(:create) : render(:new)
  end
end
