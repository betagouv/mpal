class Personne < ActiveRecord::Base
  CIVILITIES = [["Madame", "mrs"], ["Monsieur", "mr"]]

  has_one :projet

  validates :civilite, :prenom, :nom, :lien_avec_demandeur, presence: true
  validates :tel, phone: { :minimum => 10, :maximum => 12 }, allow_blank: true
  validates :email, email: true, allow_blank: true

  def fullname
    "#{prenom} #{nom}"
  end
end

