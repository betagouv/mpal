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
    can :manage, :demandeur

    if projet.locked_at.nil?
      can :manage, Projet
      can :manage, :demandeur
      can :manage, AvisImposition
      can :manage, Occupant
      can :manage, Demande
    elsif projet.demande and projet.demande.seul? and projet.users.include? user
      can :manage, Projet
      can :manage, :demandeur
      can :manage, AvisImposition
      can :manage, Occupant
      can :manage, Demande
      can :new,    Message
      can :read,   Document, category_type: "Projet",  category_id: projet.id
      can :read,   Document, category_type: "Payment", category_id: projet.payments.map(&:id)
      can :read,   :intervenant
    elsif projet.users.include? user and (!projet.demande or !projet.demande.seul?)
      can :show,   Projet
      can :index,  Projet    if user == projet.mandataire_user
      can :read,   :intervenant
      can [:new, :choose],   :choix_operateur unless projet.operateur.present?
      can :new,    Message
      can :read,   Document, category_type: "Projet",  category_id: projet.id
      can :read,   Document, category_type: "Payment", category_id: projet.payments.map(&:id)
      can :show,   Payment,  projet_id: projet.id, statut: ["propose", "demande", "en_cours_d_instruction", "paye"]
      can :index,  Payment   if projet.status_already(:transmis_pour_instruction)

      if user_can_act(user, projet)
        can :create,               Message
        can :ask_for_modification, Payment, projet_id: projet.id, action: "a_valider"
        can :ask_for_instruction,  Payment, projet_id: projet.id, action: "a_valider"
      end
    end
  end

  def agent_abilities(agent, projet)
    return if agent.blank?

    can :index,  Projet
    can :manage, Message

    return if projet.blank?
    return unless is_agent_of_projet?(agent, projet)

    #TODO voir si on laisse vraiment manage all
    can :manage, :all if agent.admin?
    can :read,   :all if agent.siege?
    can :read,   Projet if agent.dreal?

    operateur_abilities(projet)   if agent.operateur?
    instructeur_abilities(projet) if agent.instructeur?
    pris_abilities(projet)        if agent.pris?
  end

  def operateur_abilities(projet)
    can :read, :intervenant
    can :read, Projet

    return if projet.status_not_yet :en_cours

    can :create,  Document
    can :read,    Document, category_type: "Projet",  category_id: projet.id
    can :read,    Document, category_type: "Payment", category_id: projet.payments.map(&:id)

    can :destroy, (projet.documents.select { |document|
      projet.date_depot.blank? || document.created_at > projet.date_depot
    })
    can :destroy, (projet.payments.map(&:documents).flatten.select { |document|
      upload_time      = document.created_at
      submit_time      = document.category.submitted_at
      correction_time  = document.category.corrected_at
      submit_time.blank? || upload_time > (correction_time || submit_time)
    })

    if projet.status_not_yet :transmis_pour_instruction
      can :manage, Projet
      can :manage, :demandeur
      can :manage, AvisImposition
      can :manage, Occupant
      can :manage, Demande
    end

    if projet.status_already :transmis_pour_instruction
      can :create,  Payment
      can :read,    Payment, projet_id: projet.id
      can :destroy, Payment, projet_id: projet.id, statut: ["en_cours_de_montage", "propose"], action: ["a_rediger", "a_modifier"]
      can :update,  Payment, projet_id: projet.id, action: ["a_rediger", "a_modifier"]
    end

    if projet.status_already :en_cours_d_instruction
      can :ask_for_validation, Payment, projet_id: projet.id, action: ["a_rediger", "a_modifier"]
    end
  end

  def instructeur_abilities(projet)
    if projet.statut.to_sym == :transmis_pour_instruction
      can :create, :dossiers_opal
    end

    if projet.status_already :transmis_pour_instruction
      can :read, Projet
      can :read, :intervenant

      can :read, Document, category_type: "Projet",  category_id: projet.id
      can :read, Document, category_type: "Payment", category_id: projet.payments.map(&:id)

      can :index,                Payment
      can :show,                 Payment, projet_id: projet.id, statut: ["demande", "en_cours_d_instruction", "paye"]
      can :ask_for_modification, Payment, projet_id: projet.id, action: "a_instruire"
      can :send_in_opal,         Payment, projet_id: projet.id, action: "a_instruire"
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