class WelcomeController < ApplicationController
  skip_before_action :authenticate

  def index
    render layout: 'bienvenue'
  end
end
