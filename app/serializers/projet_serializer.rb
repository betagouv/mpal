class ProjetSerializer < ActiveModel::Serializer
  attributes :id, :usager, :adresse
  has_many :evenements
  class EvenementSerializer < ActiveModel::Serializer
    attributes :label, :quand
    attribute :operateur_id, if: -> { object.operateur }
  end
end
