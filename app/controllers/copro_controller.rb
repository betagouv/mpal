class CoproController < ApplicationController
  def login
    if ENV['COPRO'] != 'true'
      redirect_to root_path
    end
    @page_heading = "Je commence ma démarche"
  end


  def copro_eligibility
    if ENV['COPRO'] != 'true'
      redirect_to root_path
    end
    
    cookies["copro-commun"] = params["copro-commun"]
    cookies["copro-construction"] = params["copro-construction"]
    cookies["copro-const-date"] = params["copro-const-date"]
    cookies["copro-percent"] = params["copro-percent"]
    cookies["copro-adm"] = params["copro-adm"]
    cookies["copro-insalubrite"] = params["copro-insalubrite"]
    cookies["copro-peril"] = params["copro-peril"]
    cookies["copro-securite"] = params["copro-securite"]
    cookies["copro-saturnisme"] = params["copro-saturnisme"]
    cookies["copro-travaux"] = params["copro-travaux"]
    cookies["copro-consommation"] = params["copro-consommation"]
    cookies["copro-classif-energetique"] = params["copro-classif-energetique"]
    cookies["copro-charges-impayees"] = params["copro-charges-impayees"]
    cookies["copro-opa"] = params["copro-opa"]
    cookies["copro-travaux-commence"] = params["copro-travaux-commence"]

  end

  def information
    correct = false

    cookies["Testy_Cooky"] = "The Dudest Way to GO"

    if ENV['COPRO'] != 'true'
      redirect_to root_path
    end

    if !params[:projet_adresse_postale].present?
      redirect_to copro_login_path and return
    end

    @adresse = ""
    url_ban_check = 'https://' + ENV['API_BAN_DOMAIN'] + '/search/?q=' + params[:projet_adresse_postale] + '&autocomplete=0'

    begin
      result = Net::HTTP.get(URI.parse(URI.escape(url_ban_check))) # URI.escape because of accent chars and cedillas
      result_json = JSON.parse(result)

      result_json["features"].each do |elem|
        if elem["properties"]["label"] == params[:projet_adresse_postale] && params[:projet_adresse_postale].include?(elem["properties"]["postcode"])
          correct = true
          @adresse = params[:projet_adresse_postale]
          cookies["adresse"] = @adresse
          break
        end
      end

    rescue => e
      Rails.logger.error e.message
    end

    if correct == false
      redirect_to copro_login_path, flash: { alert: "Erreur sur l'adresse '" + params[:projet_adresse_postale] + "', veuillez la completer" } and return
    end
  end
end
