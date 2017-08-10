class Ability
  include CanCan::Ability

  def initialize(agent_or_user, projet)
    agent_or_user ||= User.new

    if agent_or_user.is_a? User
      user = agent_or_user

      return if projet.blank?

      if projet.locked_at.nil?
        can :manage, AvisImposition
        can :manage, Demande
        can :manage, :demandeur
        can :manage, :eligibility
        can :manage, Occupant
        can :manage, Projet
      elsif user == projet.user
        can :read, :eligibility
        can :read, Projet
      end
    end

    if agent_or_user.is_a? Agent
      agent = agent_or_user

      can :index, Projet

      return if projet.blank?
      return unless is_agent_of_projet?(agent, projet)

      return can :manage, :all if agent.admin?
      return can :read,   :all if agent.siege?

      if agent.pris?
        if projet.statut.to_sym == :prospect
          can :read,                   Projet
          can :recommander_operateurs, Projet
        end
      end

      if agent.instructeur?
        can :create, :dossiers_opal if projet.statut.to_sym == :transmis_pour_instruction
        can :read,   Projet         if projet.status_already :transmis_pour_instruction
      end

      if agent.operateur?
        if projet.statut.to_sym == :prospect
          can :read, Projet
        elsif projet.status_not_yet(:transmis_pour_instruction)
          can :manage, AvisImposition
          can :manage, Demande
          can :manage, :demandeur
          can :manage, Occupant
          can :manage, Projet
        else
          can :read, Projet
        end
      end
    end

    define_payment_registry_abilities(agent_or_user, projet)
    define_payment_abilities(agent_or_user, projet)
    define_document_abilities(agent_or_user, projet)
  end

private

  def define_payment_registry_abilities(agent_or_user, projet)
    can :read, PaymentRegistry, projet_id: projet.id

    if agent_or_user.try(:operateur?) && projet.status_already(:transmis_pour_instruction) && projet.payment_registry.blank?
      can :create, PaymentRegistry
    end
  end

  def define_payment_abilities(agent_or_user, projet)
    if projet.payment_registry.present?
      if agent_or_user.try(:operateur?)
        can :create,               Payment
        can :read,                 Payment, payment_registry_id: projet.payment_registry.id
        can :destroy,              Payment, payment_registry_id: projet.payment_registry.id, statut: ["en_cours_de_montage", "propose"], action: ["a_rediger", "a_modifier"]
        can :update,               Payment, payment_registry_id: projet.payment_registry.id, action: ["a_rediger", "a_modifier"]
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

  def define_document_abilities(agent_or_user, projet)
    if agent_or_user.try(:operateur?) && projet.status_already(:en_cours)
      can :create,  Document
      can :read,    Document, projet_id: projet.id
      can :update,  Document, projet_id: projet.id
      can :destroy, Document, projet_id: projet.id
    end

    if agent_or_user.try(:instructeur?)&& projet.status_already(:transmis_pour_instruction)
      can :read,    Document, projet_id: projet.id
    end

    if agent_or_user.is_a? User
      can :read,    Document, projet_id: projet.id if projet.user.present?
    end
  end

  def is_agent_of_projet?(agent, projet)
    if agent.operateur?
      agent.intervenant == projet.contacted_operateur
    elsif agent.instructeur?
      agent.intervenant == projet.invited_instructeur
    elsif agent.pris?
      agent.intervenant == projet.invited_pris
    elsif agent.siege? || agent.admin?
      true
    else
      false
    end
  end
end
