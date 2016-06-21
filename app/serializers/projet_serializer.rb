class ProjetSerializer < ActiveModel::Serializer
  attributes :id, :usager, :adresse
  has_many :evenements
  class EvenementSerializer < ActiveModel::Serializer
    attributes :label, :quand
    attribute :intervenant_id, if: -> { object.intervenant }
  end
end
