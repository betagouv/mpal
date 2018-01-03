class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :confirmable,
         #:rememberable,
         :trackable,
         :validatable

  has_many :projets_users, dependent: :destroy
  has_many :projets, through: :projets_users
  has_many :contacts, dependent: :destroy, as: :sender

  def mandataire?
    projets_users.mandataire.present?
  end

  def demandeur?
    projets_users.demandeur.present?
  end

  def projet_as_demandeur
    projets_users.demandeur.first.try(:projet)
  end


  def after_database_authentication
    projet = self.projets.first
    projet.update(:actif => 1)
  end

end
