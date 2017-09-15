class ChangeSubventions < ActiveRecord::Migration[4.2]
  def change
    remove_column :subventions, :montant
    remove_column :subventions, :projet_id
    add_belongs_to :subventions, :type_aide
    rename_table :subventions, :aides
  end
end
