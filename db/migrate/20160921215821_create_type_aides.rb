class CreateTypeAides < ActiveRecord::Migration
  def change
    create_table :type_aides do |t|
      t.string :libelle
    end
  end
end
