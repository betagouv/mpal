class PrestationChoice < ActiveRecord::Base
  belongs_to :projet
  belongs_to :prestation
end
