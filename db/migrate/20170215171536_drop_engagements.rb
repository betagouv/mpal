class DropEngagements < ActiveRecord::Migration[4.2]
  def change
    drop_table :engagements
  end
end
