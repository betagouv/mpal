class ProjetsController < ApplicationController
  include ProjetConcern

  before_action :projet_or_dossier
  before_action :assert_projet_courant, except: [:new]
  before_action :authentifie, except: [:new]

  def show
    render_show
  end

  def new
    # layout: creation_dossier
    render layout: "creation_dossier"
  end

end
