class AddPhoneToIntervenants < ActiveRecord::Migration
  def change
    add_column :intervenants, :phone, :string, null: false, default: ""
  end
end

