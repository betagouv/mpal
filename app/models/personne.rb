class Personne < ActiveRecord::Base
  has_one :projet

  validates :civilite, :prenom, :nom, :lien_avec_demandeur, presence: true

  def fullname
    "#{prenom} #{nom}"
  end
end
