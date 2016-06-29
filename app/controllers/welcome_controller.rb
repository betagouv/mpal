class WelcomeController < ApplicationController
  skip_before_action :authentifie

  def index
    render layout: 'bienvenue'
  end
end
