class Adresse < ActiveRecord::Base
  validates :ligne_1, :code_postal, :code_insee, :ville, :departement, presence: true

  def description
    "#{ligne_1}, #{code_postal} #{ville}"
  end
end
