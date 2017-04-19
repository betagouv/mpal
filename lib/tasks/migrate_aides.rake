desc "Disable old aides and add the new ones"
task migrate_aides: :environment do
  new_helps = {
      public: [
          "Aide de l'Anah",
          "Aide ASE",
          "Aide AMO",
          "Aide commune",
          "Aide EPCI",
          "Aide département",
          "Aide région",
          "Aide union européenne",
          "Caisse de retraite régime de base (CNAV/CARSAT,MSA,RSI, autres)",
          "Caisse de retraite complémentaires obligatoires (AGIRC, ARRCO, IRCANTEC, autres)",
          "Autre aide publique (ADEME, Agence de l'eau…)",
      ],
      private: [
          "Aides non publiques",
      ],
  }

  downcased_new_public_help_names = new_helps[:public].map(&:downcase)
  downcased_new_private_help_names = new_helps[:private].map(&:downcase)
  downcased_new_help_names = downcased_new_public_help_names | downcased_new_private_help_names

  Aide.publics.each do |help|
    help.update(public: false) if downcased_new_private_help_names.include?(help.libelle.downcase)
  end

  Aide.privates.each do |help|
    help.update(public: true) if downcased_new_public_help_names.include?(help.libelle.downcase)
  end

  Aide.all.each do |help|
    help.update(active: false) unless downcased_new_help_names.include?(help.libelle.downcase)
  end

  new_helps.each_pair do |attribute, help_array|
    help_array.each do |name|
      unless Aide.where("lower(libelle) = ?", name.downcase).exists?
        Aide.create libelle: name, public: attribute == :public
      end
    end
  end
end
