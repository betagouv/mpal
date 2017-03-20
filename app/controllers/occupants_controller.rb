class OccupantsController < ApplicationController
  layout 'inscription'

  before_action :dossier_ou_projet
  before_action :assert_projet_courant
  before_action :authentifie

  def index
    @occupants_a_charge = []
    nb_occupants = @projet_courant.occupants.count
    @projet_courant.nb_occupants_a_charge.times.each do |index|
      @occupants_a_charge << Occupant.new(nom: "Occupant #{index + nb_occupants + 1}")
    end
  end

  def new
    @occupant = @projet_courant.occupants.build
  end

  def edit
    @occupant = @projet_courant.occupants.where(id: params[:id]).first
    render :edit
  end

  def create
    @occupant = @projet_courant.occupants.build(occupant_params)
    if @occupant.save
      redirect_to @projet_courant
    else
      render :new
    end
  end

  def update
    @occupant = @projet_courant.occupants.where(id: params[:id]).first
    if @occupant.update_attributes(occupant_params)
      redirect_to projet_path(@projet_courant), notice: "L'occupant #{@occupant} a bien été modifié"
    else
      render :edit
    end
  end

  def destroy
    @occupant = @projet_courant.occupants.where(id: params[:id]).first
    @occupant.destroy
    redirect_to projet_path(@projet_courant)
  end

  private

  def occupant_params
    params.require(:occupant).permit(
      :civilite,
      :prenom, :nom,
      :date_de_naissance,
      :lien_demandeur, :demandeur,
      :revenus
    )
  end

end
