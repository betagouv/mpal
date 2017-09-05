class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         #:rememberable,
         :trackable,
         :validatable

  has_many :projets_users
  has_many :projets, through: :projets_users

  #TODO delete it
  def projet
    projets.first
  end
end

