class Prestation < ActiveRecord::Base
  belongs_to :projet
  belongs_to :theme
end
