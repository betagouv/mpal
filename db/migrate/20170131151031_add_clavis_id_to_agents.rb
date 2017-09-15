class AddClavisIdToAgents < ActiveRecord::Migration[4.2]
  def change
    change_table :agents do |t|
      t.string :clavis_id
      t.index  :clavis_id
    end
  end
end
