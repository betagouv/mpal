class AddAgentToProjets < ActiveRecord::Migration[4.2]
  def change
    add_reference :projets, :agent, index: true, foreign_key: true
  end
end
