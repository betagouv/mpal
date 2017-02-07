require 'rails_helper'
require 'support/api_particulier_helper'

describe Admin::IntervenantsController do
  describe "#index" do
    it "affiche la liste des intervenants", pending: true do
      # TODO
      skip
    end
  end

  describe "#import" do
    it "importe les opérateurs contenus dans un fichier CSV", pending: true do
      # TODO (voir spec/fixtures/Import intervenants.csv)
      skip
    end

    it "met à jour les opérateurs existants", pending: true do
      # TODO (voir spec/fixtures/Import intervenants.csv)
      skip
    end
  end
end
