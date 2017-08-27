class CreatePersonnes < ActiveRecord::Migration[4.2]
  def change
    create_table :personnes do |t|
      t.string :prenom
      t.string :nom
      t.string :tel
      t.string :email
      t.string :lien_avec_demandeur
    end
  end
end
