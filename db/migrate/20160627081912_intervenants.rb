class Intervenants < ActiveRecord::Migration
  def change
    add_column :intervenants, :informations, :text
  end
end
