class AddFormFieldsToContacts < ActiveRecord::Migration[5.1]
  def change
    add_column :contacts, :department,   :string
    add_column :contacts, :plateform_id, :string
    add_reference :contacts, :sender, polymorphic: true, index: true, require: false
  end
end
