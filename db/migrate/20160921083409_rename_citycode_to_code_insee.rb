class RenameCitycodeToCodeInsee < ActiveRecord::Migration[4.2]
  def change
    rename_column :projets, :citycode, :code_insee
  end
end
