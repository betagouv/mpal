class DropEngagements < ActiveRecord::Migration
  def change
    drop_table :engagements
  end
end
