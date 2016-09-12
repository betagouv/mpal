class InstructionController < ApplicationController
  skip_before_action :authentifie
  before_action :redirect_to_sign_in, unless: :agent_signed_in?
	before_action :authenticate_agent!

  def show
    
  end

  def redirect_to_sign_in
    redirect_to new_agent_session_path
  end

end
