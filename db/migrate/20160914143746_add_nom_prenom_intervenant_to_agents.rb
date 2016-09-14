class AddNomPrenomIntervenantToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :nom, :string
    add_column :agents, :prenom, :string
    add_reference :agents, :intervenant, index: true, foreign_key: true
  end
end
