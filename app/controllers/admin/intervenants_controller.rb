class Admin::IntervenantsController < AdminController
  # TODO: authentication

  def index
    @intervenants = Intervenant.all
  end
end
