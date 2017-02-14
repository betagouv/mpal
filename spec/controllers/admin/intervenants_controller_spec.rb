require 'rails_helper'
require 'support/mpal_helper'

describe Admin::IntervenantsController do

  # Génère un fichier CSV à partir d'un tableau de hashes
  def uploaded_csv(records, separator=',')
    tmp_file = Tempfile.new('import-test.csv')
    CSV.open(tmp_file, "wb", { col_sep: separator }) do |csv|
      csv << records.first.keys # header row
      records.each do |hash|
        csv << hash.values
      end
    end
    Rack::Test::UploadedFile.new(tmp_file, 'text/csv')
  end

  before(:each) do
    authenticate_as_admin
  end

  describe "GET index" do
    it "affiche la liste des intervenants" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "POST import" do
    let(:data) do
      [
        {
          raison_sociale: 'Opérateur1',
          email:          'contact@operateur1.fr'
        },
        {
          raison_sociale: 'Instructeur1',
          email:          'contact@instructeur1.fr'
        }
      ]
    end
    let(:operateur1)   { Intervenant.find_by_raison_sociale('Opérateur1') }
    let(:instructeur1) { Intervenant.find_by_raison_sociale('Instructeur1') }

    it "importe un fichier CSV séparé par des virgules" do
      post :import, { csv_file: uploaded_csv(data, ',') }
      expect(operateur1).not_to be_nil
      expect(operateur1.email).to eq 'contact@operateur1.fr'
    end

    it "importe un fichier CSV séparé par des points-virgules" do
      post :import, { csv_file: uploaded_csv(data, ';') }
      expect(operateur1).not_to be_nil
      expect(operateur1.email).to eq 'contact@operateur1.fr'
    end

    it "redirige vers la liste des intervenants en cas de succès" do
      post :import, { csv_file: uploaded_csv(data) }
      expect(response).to redirect_to(admin_intervenants_path)
      expect(flash[:notice]).to eq I18n.t('admin.intervenants.import_reussi')
    end

    it "redirige vers la liste des intervenants en cas d'erreur" do
      post :import, { csv_file: nil }
      expect(response).to redirect_to(admin_intervenants_path)
      expect(flash[:alert]).to include 'Erreur lors de l’importation'
    end

    context "avec des intervenants qui n'existent pas encore" do
      it "importe les intervenants dans la base" do
        post :import, { csv_file: uploaded_csv(data) }
        expect(operateur1).not_to be_nil
        expect(operateur1.email).to eq 'contact@operateur1.fr'
        expect(instructeur1).not_to be_nil
        expect(instructeur1.email).to eq 'contact@instructeur1.fr'
      end
    end

    context "avec des intervenants qui existent déjà" do
      before do
        create :operateur, raison_sociale: 'Opérateur1', email: 'previous-email@operateur1.fr'
      end

      it "met à jour les intervenants existants" do
        expect(operateur1).not_to be_nil
        expect(operateur1.email).to eq 'previous-email@operateur1.fr'

        post :import, { csv_file: uploaded_csv(data) }
        operateur1.reload
        expect(operateur1).not_to be_nil
        expect(operateur1.email).to eq 'contact@operateur1.fr'
      end

      it "crée les intervenants qui n'existent pas" do
        post :import, { csv_file: uploaded_csv(data) }
        expect(instructeur1).not_to be_nil
        expect(instructeur1.email).to eq 'contact@instructeur1.fr'
      end
    end

    context "avec plusieurs départements" do
      let(:data) do [{
          raison_sociale: 'Opérateur1',
          email:          'contact@operateur1.fr',
          departements:   '94, 95'
        }]
      end

      it "importe les départements" do
        post :import, { csv_file: uploaded_csv(data, ';') }
        expect(operateur1).not_to be_nil
        expect(operateur1.departements).to eq ['94', '95']
      end
    end

    context "avec plusieurs rôles" do
      let(:data) do [{
          raison_sociale: 'Instructeur1',
          email:          'contact@instructeur1.fr',
          roles:          'instructeur, pris'
        }]
      end

      it "importe les rôles" do
        post :import, { csv_file: uploaded_csv(data, ';') }
        expect(instructeur1).not_to be_nil
        expect(instructeur1.roles).to eq ['instructeur', 'pris']
      end
    end
  end
end
