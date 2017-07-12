class Ability
  include CanCan::Ability

  def initialize(agent_or_user, projet)
    agent_or_user ||= User.new

    define_payment_registry_abilities(agent_or_user, projet)
    if agent_or_user.is_a? Agent
      if agent_or_user.admin?
        can :manage, :all
        # TODO gérer pris
      elsif agent_or_user.pris?
        can [:read, :recommander_operateurs], Projet
      elsif agent_or_user.operateur? && (projet.try(:contacted_operateur) == agent_or_user.intervenant)
        if (projet.statut.to_sym == :prospect)
          can :read, Projet
        elsif (projet.statut.to_sym != :prospect) && projet.status_not_yet(:transmis_pour_instruction)
          can :manage, AvisImposition
          can :manage, Demande
          can :manage, :demandeur
          can :manage, Occupant
          can :manage, Projet
        elsif (projet.statut.to_sym != :en_cours) && (projet.statut.to_sym != :prospect)
          can :read, Projet
        end
      return
      end
    end
    if agent_or_user.is_a? User
      if projet
        if projet.locked_at.nil?
          can :manage, AvisImposition
          can :manage, Demande
          can :manage, :eligibility
          can :manage, :demandeur
          can :manage, Occupant
          can :manage, Projet
        else
          can :read, Projet
          can :read, :eligibility
        end
      end
    end
  end

private
  def define_payment_registry_abilities(agent_or_user, projet)
    if projet.present?
      project_transmited = !projet.status_not_yet(:transmis_pour_instruction)
      can :create, PaymentRegistry if agent_or_user.try(:operateur?) && project_transmited && projet.payment_registry.blank?
      can :read,   PaymentRegistry if projet.payment_registry.present?
    end
  end

end
