class ProjetsUser < ApplicationRecord
  belongs_to :projet
  belongs_to :user
end
