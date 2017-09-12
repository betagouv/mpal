class Document < ApplicationRecord
  belongs_to :projet
  mount_uploader :fichier, DocumentUploader

  validates :label, :fichier, presence: true
  validate :scan_for_viruses, if: lambda { self.fichier_changed? && (ENV["CLAMAV_ENABLED"] == "true") }

  def self.for_payment(payment)
    hash = { required: [], none: [:autres_paiement] }

    hash[:required] << (payment.type_paiement.to_sym == :avance ? :devis_paiement : :factures)
    hash[:required] << :rib
    hash[:required] << :mandat_paiement unless payment.personne_morale
    hash[:required] << :demande_signee if false # projet.mandat? quand on aura intégré les mandats
    hash[:required] << :plan_financement if payment.type_paiement.to_sym == :solde

    hash
  end

  def self.for_projet(projet)
    projet_themes = projet.themes.map(&:libelle)
    hash = { required: [], one_of: [[:devis_projet, :estimation]], none: [:autres_projet] }

    hash[:required] << :mandat_projet if false # projet.mandat? quand on aura intégré les mandats

    if projet_themes.include? "Autonomie"
      hash[:required] << :justificatif_autonomie
      hash[:required] << :diagnostic_autonomie
    end

    if projet_themes.include? "Énergie"
      hash[:required] << :evaluation_energetique
      hash[:required] << :contrat_amo if projet.invited_pris.present? #projet.operation.present?
    end

    if projet_themes.include? "SSH - petite LHI"
      hash[:one_of] << [:arrete_insalubrite_peril, :rapport_grille_insalubrite, :arrete_securite, :justificatif_saturnisme]
    end

    if projet_themes.include? "Travaux lourds"
      hash[:required] << :evaluation_energetique
      hash[:one_of]   << [:arrete_insalubrite_peril, :rapport_grille_insalubrite, :arrete_securite, :justificatif_saturnisme]

      if projet.invited_pris.present? #projet.operation.present?
        hash[:required] << :contrat_maitrise_oeuvre
        hash[:required] << :contrat_amo
      end
    end

    if projet_themes.include? "Autres travaux"
      hash[:one_of] << [:notification_agence_eau, :pv_copropriete]
    end

    hash[:required] = hash[:required].uniq
    hash[:one_of] = hash[:one_of].uniq
    # Cleanup des hashs pour gérer les doublons nécessaire si on veut être robuste
    hash
  end

  private

  def scan_for_viruses
    path = self.fichier.path
    if Clamby.virus? path
      File.delete path
      self.errors.add(:base, :virus_found)
    end
  end
end
