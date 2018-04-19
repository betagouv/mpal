class CoproController < ApplicationController
  def login
    if ENV['COPRO'] != 'true'
      redirect_to root_path
    end
    @page_heading = "Je commence ma démarche"
  end

  def next
    if ENV['COPRO'] != 'true'
      redirect_to root_path
    end
    if !params[:projet_adresse_postale].present?
      redirect_to copro_login_path
    end
    @adresse = params[:projet_adresse_postale]
  end
end
