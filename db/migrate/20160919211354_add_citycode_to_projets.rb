class AddCitycodeToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :citycode, :string
  end
end
