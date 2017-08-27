class EvenementEnregistreurJob < ApplicationJob
  queue_as :default

  def perform(attributes)
    Evenement.create(label: attributes[:label], projet: attributes[:projet], producteur: attributes[:producteur], quand: Time.now)
  end
end
