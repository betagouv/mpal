class Admin::ThemesController < Admin::BaseController
  include Administrable # See /app/controller/concerns/administrable.rb

private
  def strong_params
    %w(libelle)
  end
end
