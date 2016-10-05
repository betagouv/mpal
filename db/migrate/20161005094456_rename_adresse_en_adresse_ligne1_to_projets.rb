class RenameAdresseEnAdresseLigne1ToProjets < ActiveRecord::Migration
  def change
    change_table :projets do |t|
      t.rename :adresse, :adresse_ligne1
    end
  end
end
