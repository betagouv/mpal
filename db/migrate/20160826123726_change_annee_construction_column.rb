class ChangeAnneeConstructionColumn < ActiveRecord::Migration[4.2]
  def up
    change_column :projets, :annee_construction, :integer, default: nil
  end

  def down
    change_column :projets, :annee_construction, :integer, default: 1900
  end
end
