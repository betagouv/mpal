class Intervenants < ActiveRecord::Migration[4.2]
  def change
    add_column :intervenants, :informations, :text
  end
end
