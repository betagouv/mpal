class AddClavisServiceIdToIntervenants < ActiveRecord::Migration
  def change
    change_table :intervenants do |t|
      t.string :clavis_service_id
      t.index  :clavis_service_id
    end
  end
end
