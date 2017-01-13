class AddAgentToProjets < ActiveRecord::Migration
  def change
    add_reference :projets, :agent, index: true, foreign_key: true
  end
end
