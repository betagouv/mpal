class Ability
  include CanCan::Ability

  def initialize(agent_or_user, projet)
    agent_or_user ||= User.new

    if agent_or_user.is_a? Agent
      if agent_or_user.admin?
        can :manage, :all
      else
        can :manage, AvisImposition
        can :manage, Demande
        can :manage, :demandeur
        can :manage, Occupant
        can :manage, Projet
      end
      return
    end

    if agent_or_user.is_a? User
      if projet
        if projet.locked_at.nil?
          can :manage, AvisImposition
          can :manage, Demande
          can :manage, :demandeur
          can :manage, Occupant
          can :manage, Projet
        end
      end
    end
  end

end
