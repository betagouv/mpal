class AddEligibilityCommentaireToProjets < ActiveRecord::Migration[5.1]
  def change
  	add_column :projets, :eligibility_commentaire, :string
  end
end
