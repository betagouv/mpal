class Pjnote < ApplicationRecord
  
  belongs_to :document
  belongs_to :intervenant

  validates :projet_id, presence: true

  # validates :document_id, :projet_id, :intervenant_id, :notecontent presence: true


  def display
  	"#{notecontent}"
  end
end
