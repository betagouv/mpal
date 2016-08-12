class ChangeLienDemandeurOccupant < ActiveRecord::Migration
  def change
    change_column :occupants, :lien_demandeur, 'integer USING CAST(lien_demandeur AS integer)'
  end
end
