class RenameCitycodeToCodeInsee < ActiveRecord::Migration
  def change
    rename_column :projets, :citycode, :code_insee
  end
end
