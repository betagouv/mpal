class ProjetEntrepot
  def self.par_numero_fiscal(numero_fiscal)
    Projet.where(numero_fiscal: numero_fiscal).first
  end
end
