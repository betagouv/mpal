class AddHospitalisationToDemandes < ActiveRecord::Migration
  def change
    add_column :demandes, :hospitalisation, :boolean
  end
end
