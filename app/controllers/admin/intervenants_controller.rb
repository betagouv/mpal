class Admin::IntervenantsController < Admin::BaseController
  include Administrable # See /app/controller/concerns/administrable.rb

private
  def strong_params
    %w(raison_sociale adresse_postale clavis_service_id informations email phone)
  end

  def tabs
    h = super
    h[:agents] = { text: "Agents", icon: "user" }
    h
  end
end
