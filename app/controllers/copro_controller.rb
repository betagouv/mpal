class CoproController < ApplicationController
  def login
    if ENV['COPRO'] != 'true'
      redirect_to root_path
    end
    @page_heading = "Je commence ma démarche"
  end

  def next
    correct = false

    if ENV['COPRO'] != 'true'
      redirect_to root_path
    end
    if !params[:projet_adresse_postale].present?
      redirect_to copro_login_path
    end

    @adresse = ""
    url_ban_check = 'https://' + ENV['API_BAN_DOMAIN'] + '/search/?q=' + params[:projet_adresse_postale] + '&autocomplete=0'

    begin
      result = Net::HTTP.get(URI.parse(URI.escape(url_ban_check))) # URI.escape because of accent chars and cedillas
    rescue => e
      Rails.logger.error e.message
    end

    begin
      result_json = JSON.parse(result)

      result_json["features"].each do |elem|
        if elem["properties"]["label"] == params[:projet_adresse_postale]
          correct = true
          @adresse = params[:projet_adresse_postale]
        end
      end

    rescue => e
      Rails.logger.error e.message
    end

    if correct == false
      redirect_to copro_login_path, flash: { alert: "Erreur sur l'adresse, veuillez la completer" }
    end
  end
end
