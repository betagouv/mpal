class AddAgentInstructeurIdToProjets < ActiveRecord::Migration
  def change
    rename_column   :projets, :agent_id, :agent_operateur_id
    add_reference   :projets, :agent_instructeur, references: :agents, index: true
    add_foreign_key :projets, :agents, column: :agent_instructeur_id
  end
end

