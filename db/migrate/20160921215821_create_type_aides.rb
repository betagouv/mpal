class CreateTypeAides < ActiveRecord::Migration[4.2]
  def change
    create_table :type_aides do |t|
      t.string :libelle
    end
  end
end
