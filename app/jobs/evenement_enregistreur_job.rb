class EvenementEnregistreurJob < ActiveJob::Base
  queue_as :default

  def perform(attributes)
    Evenement.create(label: attributes[:label], projet_id: attributes[:projet_id], intervenant_id: attributes[:intervenant_id], quand: Time.now)
  end
end
