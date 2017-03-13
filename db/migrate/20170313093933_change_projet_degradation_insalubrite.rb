class ChangeProjetDegradationInsalubrite < ActiveRecord::Migration
  def change
    change_column :projets, :note_degradation, :decimal, :precision => 10, :scale => 6
    change_column :projets, :note_insalubrite, :decimal, :precision => 10, :scale => 6
  end
end
