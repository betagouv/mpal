class AddCitycodeToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :citycode, :string
  end
end
