class ProjetSerializer < ActiveModel::Serializer
  attributes :id, :adresse
  has_many :occupants
  has_many :evenements

  def adresse
    object.description_adresse
  end

  class OccupantSerializer < ActiveModel::Serializer
    attributes :prenom, :nom, :demandeur
  end

  class EvenementSerializer < ActiveModel::Serializer
    attribute :quand
    attribute :description
  end
end
