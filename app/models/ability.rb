class Ability
  include CanCan::Ability

  def initialize(admin)
    agent ||= Agent.new # guest user (not logged in)
    if agent.admin?
      can :manage, :all
      return
    end
    can [:index], Agent
    can [:update], Agent, id: agent.id
    can do |action, subject_class, subject|
      ![Agent].include?(subject_class)
    end
  end
end
