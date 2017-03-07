require 'charlock_holmes'
require 'acsv'

class Admin::IntervenantsController < Admin::BaseController
  include Administrable # See /app/controller/concerns/administrable.rb

  def import
    begin
      _import_csv!(params[:csv_file])
    rescue => e
      return redirect_to admin_intervenants_path, alert: "Erreur lors de l’importation : #{e.message}"
    end
    redirect_to admin_intervenants_path, notice: I18n.t('admin.intervenants.import_reussi')
  end

private

  def _import_csv!(file)
    if file.blank?
      raise "Le fichier CSV est manquant."
    end

    begin
      # Use ACSV to auto-detect the file encoding and column separator
      @csv = ACSV::CSV.read(file.tempfile.path, headers: true, converters: ->(f) { f.try(:strip) })
    rescue => e
      raise "Le fichier CSV ne peut être lu (#{e.message})."
    end

    @csv.each do |row|
      begin
        _create_or_update_intervenant!(row)
      rescue => e
        raise "La mise à jour de l’intervenant '#{row['raison_sociale']}' a échoué (#{e.message})."
      end
    end
  end

  def _create_or_update_intervenant!(row)
    raison_sociale = row['raison_sociale']
    intervenant = Intervenant.where('lower(raison_sociale) = lower(?)', raison_sociale).first_or_create(raison_sociale: raison_sociale)
    intervenant.assign_attributes(row.to_hash)
    if row['roles']
      intervenant.roles = row['roles'].split(',').map(&:strip)
    end
    if row['departements']
      intervenant.departements = row['departements'].split(',').map(&:strip)
    end
    intervenant.save!
  end

  def strong_params
    %w(raison_sociale adresse_postale clavis_service_id informations email)
  end

  def tabs
    h = super
    h[:agents] = { text: "Agents", icon: "user" }
    h
  end
end
