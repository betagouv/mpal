class AddAdresseToProjetCopro < ActiveRecord::Migration[5.1]
  def change
    add_belongs_to :projet_copros, :adresses, index: true, foreign_key: true
  end
end
