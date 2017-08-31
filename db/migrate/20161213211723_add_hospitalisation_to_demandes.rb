class AddHospitalisationToDemandes < ActiveRecord::Migration[4.2]
  def change
    add_column :demandes, :hospitalisation, :boolean
  end
end
