require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'
require 'support/rod_helper'

feature "Choisir un mot de passe :" do
  let!(:projet) { create :projet, :prospect }
  let!(:pris) {   create :pris, departements: ["75"] }

end

