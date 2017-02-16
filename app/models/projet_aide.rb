class ProjetAide < ActiveRecord::Base
  include LocalizedModelConcern

  belongs_to :projet
  belongs_to :aide

  localized_numeric_setter :montant
end
