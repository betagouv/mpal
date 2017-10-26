class InvitationsController < ApplicationController
  before_action :assert_projet_courant, except: [:new, :create]
end
