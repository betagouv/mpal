class Document < ApplicationRecord
  belongs_to :projet
  mount_uploader :fichier, DocumentUploader

  validates :label, :fichier, presence: true
  validate :scan_for_viruses, if: lambda { self.fichier_changed? && (ENV["CLAMAV_ENABLED"] == "true") }

  private

  def scan_for_viruses
    path = self.fichier.path
    if Clamby.virus? path
      File.delete path
      self.errors.add(:base, :virus_found)
    end
  end
end
