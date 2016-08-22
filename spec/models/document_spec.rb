require 'rails_helper'
describe Document do
  it { expect(FactoryGirl.create(:document)).to be_valid }

  it { is_expected.to validate_presence_of(:label).with_message(I18n.t('erreur_label_manquant', scope: 'projets.demande.messages')) }
  it { is_expected.to validate_presence_of(:fichier).with_message(I18n.t('erreur_fichier_manquant', scope: 'projets.demande.messages')) }
  it { is_expected.to belong_to(:projet) }

end
