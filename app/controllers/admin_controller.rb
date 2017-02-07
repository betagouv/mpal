class AdminController < ApplicationController
  layout 'logged_in'

  skip_before_action :assert_projet_courant
  skip_before_action :authentifie

  # TODO:
  # - handle authentication with secret cookie
end
