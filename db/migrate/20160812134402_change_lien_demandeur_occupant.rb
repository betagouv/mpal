class ChangeLienDemandeurOccupant < ActiveRecord::Migration[4.2]
  def change
    change_column :occupants, :lien_demandeur, 'integer USING CAST(lien_demandeur AS integer)'
  end
end
