class Tool < ActiveRecord::Base

  def self.reset_base
    Evenement.delete_all
    Occupant.delete_all
    Invitation.delete_all
    Projet.delete_all
  end
end
