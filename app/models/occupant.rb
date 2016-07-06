class Occupant < ActiveRecord::Base

  belongs_to :projet

  validates :nom, :prenom, :date_de_naissance, presence: true

  enum civilite: [ 'mr', 'mme']

  scope :sans_revenus, ->   { where(:revenu.in? [nil, 0]) }

  def to_s
    "#{prenom} #{nom}"
  end
end
