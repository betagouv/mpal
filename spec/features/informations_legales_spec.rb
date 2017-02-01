require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Le visiteur du site a acces à des informations légales concernant la plate-forme" do

  let(:projet) { create :projet }

  scenario "Le visiteur peut voir les CGU lorsqu'il clique sur le lien correspondant" do
    skip
    signin(projet.numero_fiscal, projet.reference_avis)
    visit projet_path(projet)
    expect(page.current_path).to eq(projet_path(projet))
    click_link I18n.t('menu_bas.cgu')
    expect(page.current_path).to eq(informations_cgu_path)
  end

  scenario "Le visiteur peut voir la FAQ lorsqu'il clique sur le lien correspondant" do
    skip
    signin(projet.numero_fiscal, projet.reference_avis)
    visit projet_path(projet)
    click_link I18n.t('menu_bas.faq')
    expect(page.current_path).to eq(informations_faq_path)
  end

  scenario "Le visiteur peut voir les mentions légales lorsqu'il clique sur le lien correspondant" do
    signin(projet.numero_fiscal, projet.reference_avis)
    visit projet_path(projet)
    click_link I18n.t('menu_bas.mentions_legales')
    expect(page.current_path).to eq(informations_mentions_legales_path)
  end

  scenario "Le visiteur peut contacter l'administrateur de la plate-forme" do
    skip
  end
end
