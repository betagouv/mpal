def signin(numero_fiscal, reference_avis)
  visit new_session_path
  fill_in :numero_fiscal, with: numero_fiscal
  fill_in :reference_avis, with: reference_avis
  click_button I18n.t('sessions.nouvelle.action')
end
