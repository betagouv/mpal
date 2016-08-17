module EligibiliteHelper
  def calcul_revenu_fiscal_reference_total(annee)
    @projet_courant.calcul_revenu_fiscal_reference_total(annee)
  end

  def calcul_preeligibilite(annee)
    plafond = @projet_courant.preeligibilite(annee)
    affiche_message_eligibilite(plafond)
  end

  def affiche_message_eligibilite(revenus)
    liste_message = {
      tres_modeste: 'Très Modeste',
      modeste: 'Modeste',
      plafond_depasse: 'Plafond dépassé'
    }
    liste_message[revenus.to_sym]
  end
end
