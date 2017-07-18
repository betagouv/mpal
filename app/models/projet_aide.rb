class ProjetAide < ActiveRecord::Base
  include LocalizedModelConcern

  belongs_to :projet
  belongs_to :aide

  amountable :amount

  delegate :libelle, to: :aide
  validates :amount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 999999999 }
  validate :validate_number_less_than_9_digits

  def validate_number_less_than_9_digits

    # MODIFIER LE MSG ERREUR
    value = send("localized_amount").to_s.gsub(/\s+/, "")
    unless value =="" || value =~ /^\d{1,8}(,?\d{0,2})?$/
      errors.add(:amount, "doit être inférieur à '100 000 000'")
    end
  end
end

