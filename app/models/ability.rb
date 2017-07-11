class Ability
  include CanCan::Ability

  def initialize(agent_or_user, projet)
    agent_or_user ||= User.new

    define_payment_registry_abilities(agent_or_user, projet)

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

private
  def define_payment_registry_abilities(agent_or_user, projet)
    project_transmited = !projet.status_not_yet(:transmis_pour_instruction)

    can :create, PaymentRegistry if agent_or_user.try(:operateur?) && project_transmited && projet.payment_registry.blank?
    can :read,   PaymentRegistry if projet.payment_registry.present?
  end

end
