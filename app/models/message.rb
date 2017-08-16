class Message < ActiveRecord::Base
  belongs_to :auteur, polymorphic: true
  belongs_to :projet

  validates :auteur, :projet, :corps_message, presence: true
end

