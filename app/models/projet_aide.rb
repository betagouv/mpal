class ProjetAide < ActiveRecord::Base
  belongs_to :projet
  belongs_to :aide
end
