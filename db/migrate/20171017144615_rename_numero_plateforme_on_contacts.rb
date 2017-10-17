class RenameNumeroPlateformeOnContacts < ActiveRecord::Migration[5.1]
  def change
    rename_column :contacts, :plateform_id, :numero_plateforme
  end
end

