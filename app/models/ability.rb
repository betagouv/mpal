class Ability
  include CanCan::Ability

  def initialize(subject, agent_or_user, projet)
    if agent_or_user == :agent
      agent_abilities(subject, projet)
    elsif agent_or_user == :user
      user_abilities(subject, projet)
    end
  end

private

  def user_abilities(user, projet)
    return if projet.blank?

    can :read, :eligibility
    can :departement_non_eligible, :demandeur

    if projet.locked_at.nil?
      can :manage, Projet
      can :manage, :demandeur
      can :manage, AvisImposition
      can :manage, Occupant
      can :manage, Demande
    elsif projet.users.include? user
      can :show,   Projet
      can :index,  Projet           if user == projet.mandataire_user
      can :read,   :intervenant
      can :new,    Message
      can :create, Message          if user_can_act(user, projet)
      can :read,   Document,        category: projet
      can :read,   PaymentRegistry, projet_id: projet.id

      if projet.payment_registry.present?
        can :read, Payment,  payment_registry_id: projet.payment_registry.id, statut: ["propose", "demande", "en_cours_d_instruction", "paye"]
        can :read, Document, category: projet.payment_registry.payments
      end

      if user_can_act(user, projet) && projet.payment_registry.present?
        can :ask_for_modification, Payment, payment_registry_id: projet.payment_registry.id, action:  "a_valider"
        can :ask_for_instruction,  Payment, payment_registry_id: projet.payment_registry.id, action:  "a_valider"
      end
    end
  end

  def agent_abilities(agent, projet)
    return if agent.blank?

    can :index,  Projet
    can :manage, Message

    return if projet.blank?
    return unless is_agent_of_projet?(agent, projet)

    return can :manage, :all if agent.admin?
    return can :read,   :all if agent.siege?

    can :read, PaymentRegistry, projet_id: projet.id

    operateur_abilities(projet)   if agent.operateur?
    instructeur_abilities(projet) if agent.instructeur?
    pris_abilities(projet)        if agent.pris?
  end

  def operateur_abilities(projet)
    can :read, :intervenant
    can :read, Projet

    return if projet.statut.to_sym == :prospect

    if projet.status_already :en_cours
      can :create,  Document
      can :read,    Document, category: projet
      can :destroy, Document do |document|
        can :destroy, document, category: projet if projet.date_depot.blank? || document.created_at > projet.date_depot
      end
    end

    if projet.status_not_yet :transmis_pour_instruction
      can :manage, Projet
      can :manage, :demandeur
      can :manage, AvisImposition
      can :manage, Occupant
      can :manage, Demande
    end

    if projet.status_already(:transmis_pour_instruction) && projet.payment_registry.blank?
      can :create, PaymentRegistry
    end

    if projet.payment_registry.present?
      can :read,                 Document, category: projet.payment_registry.payments
      can :destroy,              Document, category: projet.payment_registry.payments

      can :create,               Payment
      can :read,                 Payment, payment_registry_id: projet.payment_registry.id
      can :destroy,              Payment, payment_registry_id: projet.payment_registry.id, statut: ["en_cours_de_montage", "propose"], action: ["a_rediger", "a_modifier"]
      can :update,               Payment, payment_registry_id: projet.payment_registry.id, action: ["a_rediger", "a_modifier"]
      can :ask_for_validation,   Payment, payment_registry_id: projet.payment_registry.id, action: ["a_rediger", "a_modifier"] unless projet.status_not_yet(:en_cours_d_instruction)
    end
  end

  def instructeur_abilities(projet)
    if projet.statut.to_sym == :transmis_pour_instruction
      can :create, :dossiers_opal
    end

    if projet.status_already :transmis_pour_instruction
      can :read, Projet
      can :read, :intervenant
      can :read, Document, category: projet
    end

    if projet.payment_registry.present?
      can :read,                 Document, category: projet.payment_registry.payments

      can :read,                 Payment, payment_registry_id: projet.payment_registry.id, statut: ["demande", "en_cours_d_instruction", "paye"]
      can :ask_for_modification, Payment, payment_registry_id: projet.payment_registry.id, action: "a_instruire"
      can :send_in_opal,         Payment, payment_registry_id: projet.payment_registry.id, action: "a_instruire"
    end
  end

  def pris_abilities(projet)
    if projet.statut.to_sym == :prospect
      can :read,                   :intervenant
      can :read,                   Projet
      can :recommander_operateurs, Projet
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

  def user_can_act(user, projet)
    (user == projet.demandeur_user && projet.mandataire_user.blank?) || user == projet.mandataire_user
  end
end
