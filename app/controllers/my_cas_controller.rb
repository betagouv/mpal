class MyCasController < Devise::CasSessionsController
  skip_before_action :authentifie

  def new
    if params[:from] == "opal"
      my_cas_uri = URI.parse(cas_login_url)
      my_cas_uri.query += "&from=opal&projet_id=#{params[:projet_id]}"
      session[:projet_id_from_opal] = params[:projet_id]
      redirect_to(my_cas_uri.to_s)
    else
      super
    end
  end

  def xxxservice
    puts ">>>>> session paraams #{session[:projet_id_from_opal]} "
    if id = session[:projet_id_from_opal]
      projet = Projet.find(id)
      session.delete(:projet_id_from_opal)
      redirect_to(projet_path(projet))
    else
      super
    end
  end

end
