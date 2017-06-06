class Users::PasswordsController < Devise::PasswordsController
  include ApplicationConcern

  layout "creation_dossier"

  # GET /resource/password/new
  def new
    @page_heading = "Mot de passe perdu ?"
    super
  end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(resource_name)
    root_path
  end
end

