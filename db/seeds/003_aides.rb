class Seeder
	HELPS = {
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

	def seed_aides
		table_name = 'aides'
		seeding table_name
		progress do
			HELPS.each_pair do |attribute, help_array|
				help_array.each do |name|
					Aide.find_or_create_by!(libelle: name).update(public: attribute == :public)
					ahead!
				end
			end
		end
	end
end
