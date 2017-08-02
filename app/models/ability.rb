class Ability
  include CanCan::Ability

  def initialize(agent_or_user, projet)
    agent_or_user ||= User.new

    return can :index, Projet if projet.blank?

    define_payment_registry_abilities(agent_or_user, projet)
    define_payment_abilities(agent_or_user, projet)

    if agent_or_user.is_a? Agent
      if agent_or_user.admin?
        can :manage, :all
        return
      end
      if agent_or_user.siege?
        can :read, AvisImposition
        can :read, Demande
        can :read, :eligibility
        can :read, :demandeur
        can :read, Occupant
        can :read, Projet
      end
      if agent_or_user.pris? && projet.statut.to_sym == :prospect && projet.invited_pris == agent_or_user.intervenant
        can [:read, :recommander_operateurs], Projet
      elsif agent_or_user.instructeur?
        if !projet.status_not_yet(:transmis_pour_instruction) &&  projet.invited_instructeur == agent_or_user.intervenant
          can :read, Projet
        end
        if projet.statut.to_sym == :transmis_pour_instruction &&  projet.invited_instructeur == agent_or_user.intervenant
          can :manage, :dossiers_opal
        end

      elsif agent_or_user.operateur? && projet.contacted_operateur == agent_or_user.intervenant
        if projet.statut.to_sym == :prospect
          can :read, Projet
        elsif projet.statut.to_sym != :prospect && projet.status_not_yet(:transmis_pour_instruction)
          can :manage, AvisImposition
          can :manage, Demande
          can :manage, :demandeur
          can :manage, Occupant
          can :manage, Projet
        elsif projet.statut.to_sym != :en_cours && projet.statut.to_sym != :prospect
          can :read, Projet
        end
      end
    end

    if agent_or_user.is_a? User
      return if projet.blank?
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

private
  def define_payment_registry_abilities(agent_or_user, projet)
    if projet.present?
      if projet.payment_registry.blank?
        project_transmited = !projet.status_not_yet(:transmis_pour_instruction)

        can :create, PaymentRegistry if agent_or_user.try(:operateur?) && project_transmited
      else
        can :read,   PaymentRegistry, projet_id: projet.id
      end
    end
  end

  def define_payment_abilities(agent_or_user, projet)
    alias_action :new,  :create, to: :add
    alias_action :edit, :update, to: :modify

    if projet.payment_registry.present?
      if agent_or_user.try(:operateur?)
        can :add,                  Payment
        can :read,                 Payment, payment_registry_id: projet.payment_registry.id
        can :destroy,              Payment, payment_registry_id: projet.payment_registry.id, statut: ["en_cours_de_montage", "propose"], action: ["a_rediger", "a_modifier"]
        can :modify,               Payment, payment_registry_id: projet.payment_registry.id, action: ["a_rediger", "a_modifier"]
        can :ask_for_validation,   Payment, payment_registry_id: projet.payment_registry.id, action: ["a_rediger", "a_modifier"] unless projet.status_not_yet(:en_cours_d_instruction)
      end

      if agent_or_user.try(:instructeur?)
        can :read,                 Payment, payment_registry_id: projet.payment_registry.id, statut: ["demande", "en_cours_d_instruction", "paye"]
        can :ask_for_modification, Payment, payment_registry_id: projet.payment_registry.id, action: "a_instruire"
        can :send_in_opal,         Payment, payment_registry_id: projet.payment_registry.id, action: "a_instruire"
      end

      if agent_or_user.is_a? User
        can :read,                 Payment, payment_registry_id: projet.payment_registry.id, statut: ["propose", "demande", "en_cours_d_instruction", "paye"]
        can :ask_for_modification, Payment, payment_registry_id: projet.payment_registry.id, action:  "a_valider"
        can :ask_for_instruction,  Payment, payment_registry_id: projet.payment_registry.id, action:  "a_valider"
      end
    end
  end
end
