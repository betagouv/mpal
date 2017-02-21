require 'csv'

class Admin::IntervenantsController < Admin::BaseController

  def index
    @intervenants = Intervenant.all
  end

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
      @csv = _parse_csv(file)
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

  def _parse_csv(file)
    csv_content = file.read
    col_separators = [',', ';', '\t']
    best_separator = col_separators
      .max_by { |separator|
        csv = CSV.parse(csv_content, headers: true, col_sep: separator)
        csv.headers.count
      }
    CSV.parse(csv_content, headers: true, col_sep: best_separator)
  end

  def _create_or_update_intervenant!(row)
    intervenant = Intervenant.find_or_create_by(raison_sociale: row['raison_sociale'])
    intervenant.assign_attributes(row.to_hash)
    if row['roles']
      intervenant.roles = row['roles'].split(',').map(&:strip)
    end
    if row['departements']
      intervenant.departements = row['departements'].split(',').map(&:strip)
    end
    intervenant.save!
  end
end
