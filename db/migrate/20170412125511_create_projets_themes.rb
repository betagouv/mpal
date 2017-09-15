class CreateProjetsThemes < ActiveRecord::Migration[4.2]
  def change
    create_table :projets_themes, id: false do |t|
      t.references :projet, index: true
      t.references :theme,  index: true
    end
  end
end
