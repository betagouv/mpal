class HomepageController < ApplicationController
  before_action :redirect_to_project_if_exists

  def index
    @homepage = true
  end
end

