class OccupantsController < ApplicationController
  layout 'inscription'

  before_action :dossier_ou_projet
  before_action :assert_projet_courant
  before_action :authentifie

  def index
    @occupant = @projet_courant.avis_impositions.first.occupants.build(occupant_params)

    if request.post?
      if occupant_params?
        if @occupant.save
          # Clear form fields
          @occupant = @projet_courant.avis_impositions.first.occupants.build
        end
      else
        return redirect_to etape2_description_projet_path(@projet_courant)
      end
    end

    @occupants = @projet_courant.occupants.to_a.find_all(&:persisted?)
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

    if @occupant.can_be_deleted? && @occupant.destroy
      flash[:notice] = t("occupants.delete.success", fullname: @occupant.fullname)
    else
      flash[:alert] = t("occupants.delete.error")
    end
    redirect_to projet_occupants_path(@projet_courant)
  end

private
  def occupant_params
    params.fetch(:occupant, {}).permit(
      :civilite,
      :prenom,
      :nom,
      :date_de_naissance,
      :lien_demandeur,
      :demandeur,
      :revenus
    )
  end

  def occupant_params?
    occupant_params.any? { |attribute, value| value.present? }
  end
end
