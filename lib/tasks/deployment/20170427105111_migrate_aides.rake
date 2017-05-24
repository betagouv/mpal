namespace :after_party do
  desc 'Deployment task: migrate_aides'
  task migrate_aides: :environment do
    puts "Running deploy task 'migrate_aides'" unless Rake.application.options.quiet

    downcased_new_public_help_names = new_helps[:public].map(&:downcase)
    downcased_new_private_help_names = new_helps[:private].map(&:downcase)
    downcased_new_help_names = downcased_new_public_help_names | downcased_new_private_help_names

    Aide.public_assistance.each do |help|
      help.update(public: false) if downcased_new_private_help_names.include?(help.libelle.downcase)
    end

    Aide.not_public_assistance.each do |help|
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

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20170427105111'
  end

private

  def new_helps
    {
      public: [
        "Aide de l'Anah",
        "Aide ASE",
        "Aide AMO",
        "Aide commune",
        "Aide EPCI",
        "Aide département",
        "Aide région",
        "Aide union européenne",
        "Caisse de retraite régime de base (CNAV/CARSAT, MSA, RSI, autres)",
        "Caisse de retraite complémentaires obligatoires (AGIRC, ARRCO, IRCANTEC, autres)",
        "Autre aide publique (ADEME, Agence de l'eau…)",
      ],
      private: [
        "Aides non publiques",
      ],
    }
  end
end
