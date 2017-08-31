class AddPhoneToIntervenants < ActiveRecord::Migration[4.2]
  def change
    add_column :intervenants, :phone, :string, null: false, default: ""
  end
end

