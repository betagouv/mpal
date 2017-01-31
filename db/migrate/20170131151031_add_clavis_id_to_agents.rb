class AddClavisIdToAgents < ActiveRecord::Migration
  def change
    change_table :agents do |t|
      t.string :clavis_id
      t.index  :clavis_id
    end
  end
end
